class Member < ActiveRecord::Base
    has_and_belongs_to_many :organizations
    has_many :pull_requests

    def open_pull_requests_count
      pull_requests.open.size
    end

    def merged_pull_requests_count
      pull_requests.merged.size
    end

    def pull_requests_weight
      pull_requests.map(&:weight_total).inject(0, &:+)
    end
    


end
