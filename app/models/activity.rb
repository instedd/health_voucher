class Activity < ActiveRecord::Base
  belongs_to :user

  scope :for_listing, ->{ includes(:user) }

  paginates_per 15
end
