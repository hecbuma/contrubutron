class QueryJob < ActiveJob::Base
  queue_as :default

  def perform(organization, token, user)
    organization.fetch_data token, user
  end
end
