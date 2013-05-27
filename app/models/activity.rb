class Activity < ActiveRecord::Base
  belongs_to :user

  attr_accessible :description, :object_class, :object_id

  scope :for_listing, includes(:user)

  paginates_per 15
end
