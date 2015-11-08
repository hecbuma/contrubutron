class Repository < ActiveRecord::Base
  has_many :pull_requests
end
