class Site < ActiveRecord::Base
  attr_accessible :name, :training

  has_many :clinics
  has_many :mentors
  has_many :pacients, :through => :mentors
  has_many :cards

  validates_presence_of :name
  validates_length_of :name, :maximum => 100
end
