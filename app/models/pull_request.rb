class PullRequest < ActiveRecord::Base
  belongs_to :member
  belongs_to :repository
end