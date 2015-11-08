class GithubService
  attr_accessor :github, :token

  def initialize(token)
    @token = token
    @github = Github.new oauth_token: token
  end

  def get_organizations
    Rails.cache.fetch("#{cache_key}/organizations/list", expires_in: 6.hours) do
      orgs = []
      organizations = github.orgs.list
      organizations.each_page do |page|
        page.each do |org|
          orgs << org
        end
      end

      orgs.sort_by { |org| org.name }
    end
  end

  def get_pull_request(repo, user, number)
    Rails.cache.fetch("#{cache_key}/pulls/#{repo}/#{user}/#{number}/get", expires_in: 6.hours) do
    begin
      github.pull_requests.get(user: user, repo: repo, number: number)
    rescue => e
      nil
    end
    end
  end


  def get_members(organization)
    Rails.cache.fetch("#{cache_key}/members/#{organization}/list", expires_in: 6.hours) do
      github.orgs.members.list(organization['login'], per_page: '100').to_a
    end
  end

  private

    def cache_key
      Digest::MD5.hexdigest("#{@token}")
    end

end
