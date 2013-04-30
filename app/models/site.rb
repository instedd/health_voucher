class Site < ActiveRecord::Base
  attr_accessible :name, :training

  has_many :clinics
  has_many :mentors
  has_many :pacients, :through => :mentors
  has_many :cards
end
