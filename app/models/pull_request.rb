class PullRequest < ActiveRecord::Base
  belongs_to :member
  belongs_to :repository

  scope :merged, -> { where(merged: true) }
  scope :open, -> { where(state: 'open') }

  def weight
    res = ((((additions || 0) * 0.01) + ((deletions || 0) * 0.02))/2).round(2)
  end

  def weight_total
    weights = weight * repository.weight
    total   = merged ? weights * 1 : weights * 0.05
  end

end
