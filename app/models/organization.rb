class Organization < ActiveRecord::Base
  include AASM

  has_and_belongs_to_many :users
  has_and_belongs_to_many :members, dependent: :destroy

  aasm do
    state :created, :initial => true
    state :fetching
    state :failed
    state :completed

    event :fetch do
      transitions :from => [:created, :failed], :to => :fetching
    end

    event :fail do
      transitions :from => :fetching, :to => :failed
    end

    event :complete do
      transitions :from => :fetching, :to => :completed
    end
  end

  # STATS
  def open_pull_requests
    members.map(&:open_pull_requests_count).inject(0, &:+)
  end

  def merged_pull_requests
    members.map(&:merged_pull_requests_count).inject(0, &:+)
  end

  def rank_members
    rank = members.sort {|a,b| a.pull_requests_weight <=> b.pull_requests_weight}.reverse
    rank.take(8)
  end

  def no_rank_members
    members.to_a.delete_if{|m| rank_members.include? m}
  end

  def repository_count
    Repository.per_organization(self.id).count
  end

  def repository_rank
    rank = []
    Repository.per_organization(self.id).each do |repo|
      rank << [repo.pull_requests.where(member_id: self.member_ids).count, repo]
    end
    rank = rank.sort {|a,b| a.first <=> b.first}.reverse
    rank.take(12)
  end

  # DATA MINING
  def move_to_queue(token, user)
    self.fetch!
    QueryJob.perform_later self, token, user
  end

  def fetch_data(token, current_user)
    begin

      multiple_lists = members.map(&:name).each_slice(4).to_a
      elements = members.map(&:name).join('|')
      totalRows = 0
      rows      = []
      year      = 5
      # TDOO: double check time range in google
      # (4..5).each do |year|
        (1..12).each do |month|
          year = 6 if year == 5 && month == 12
          top_month = month == 12 ? 1 : month + 1
          query = "SELECT actor.login, repo.name, repo.url, type, payload FROM (
            TABLE_DATE_RANGE([githubarchive:day.events_],
              TIMESTAMP('201#{year-1}-#{month}-01'),
              TIMESTAMP('201#{year}-#{top_month}-01')
            ))
          WHERE type = 'PullRequestEvent'  and
          (REGEXP_MATCH(actor.login,r'#{elements}'))"
          begin
            response = $bq.query(query)
          rescue => e
            puts e
            puts query
            response = nil
          end
          next if response.nil?
          totalRows  = totalRows + response["totalRows"].to_i
          rows << response["rows"]
        end
      # end

      if totalRows > 0
        rows.flatten.each do |row|
          next if row.nil?
          next if row.empty?
          row = row["f"]
          payload  = JSON.parse(row[4]["v"])
          member = Member.find_by(name: row[0]["v"])

          if member && payload["action"] == 'opened'
            stars    = payload["pull_request"]["base"]["repo"]["stargazers_count"].to_i
            watchers = payload["pull_request"]["base"]["repo"]["watchers_count"].to_i
            forks    = payload["pull_request"]["base"]["repo"]["forks_count"].to_i

            repo = Repository.create_with(profile: row[2]["v"]).find_or_initialize_by(name: row[1]["v"])
            repo.save!
            repo.update_column(:stars, stars) unless repo.stars == stars
            repo.update_column(:watchers, watchers) unless repo.watchers == watchers
            repo.update_column(:forks, forks) unless repo.forks == forks

            repo_name   = payload["pull_request"]["base"]["repo"]["name"]
            user        = payload["pull_request"]["base"]["user"]["login"]
            number      = payload["pull_request"]["number"]

            api_pull_request = GithubService.new(token).get_pull_request(repo_name, user, number)

            next if api_pull_request.nil?
            puts api_pull_request.body['html_url']

            pull_request_record = PullRequest.find_or_initialize_by(url: api_pull_request.body['html_url'])
            pull_request_record.save if pull_request_record.new_record?
            pull_request = pull_request_record.update_attributes!(payload: row[4]["v"],
                                                                url: api_pull_request.body['html_url'],
                                                                state: api_pull_request.body['state'],
                                                                comments: api_pull_request.body['comments'],
                                                                review_comments: api_pull_request.body['review_coments'],
                                                                additions: api_pull_request.body['additions'],
                                                                deletions: api_pull_request.body['deletions'],
                                                                changed_files: api_pull_request.body['changed_files'],
                                                                merged: api_pull_request.body['merged'],
                                                                repository_id: repo.id,
                                                                member_id: member.id)



          end
        end
      end

    rescue => e
      self.fail!
      message = ""
      message << e.message
      message << e.backtrace.join("\n")
      errors[:error] = message
      puts message
    end
    if errors.empty?
      self.complete!
      NotifyUsers.notify(self, current_user).deliver_now if current_user.email.present?
    end
  end

end
