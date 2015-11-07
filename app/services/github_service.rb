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
