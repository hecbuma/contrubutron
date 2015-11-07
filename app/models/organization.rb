class Organization < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_and_belongs_to_many :members, dependent: :destroy
end
