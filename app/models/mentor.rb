class Mentor < ActiveRecord::Base
  attr_accessible :name

  belongs_to :site

  has_many :pacients
end
