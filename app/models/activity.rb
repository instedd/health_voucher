class Activity < ActiveRecord::Base
  belongs_to :user

  attr_accessible :description, :object_class, :object_id
end
