class QueryJob < ActiveJob::Base
  queue_as :default

  def perform(organization, token)
    organization.fetch_data token
  end
end
