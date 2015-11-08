class Repository < ActiveRecord::Base
  has_many :pull_requests

  scope :per_organization, -> (org_id) {joins(pull_requests: {member: :organizations}).where('organizations.id = ?', org_id).uniq}

  def weight
    res = ((((stars || 0) * 0.01) + ((forks || 0) * 0.01) + ((watchers || 0) * 0.01))/3).round(2)
  end

end
