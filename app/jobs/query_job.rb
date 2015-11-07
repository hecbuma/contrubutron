class QueryJob < ActiveJob::Base
  queue_as :default

  def perform(organization)
    organization.fetch_data
  end
end
