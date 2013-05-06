class Site < ActiveRecord::Base
  attr_accessible :name, :training

  belongs_to :user
  has_many :clinics, :dependent => :destroy
  has_many :mentors, :dependent => :destroy
  has_many :pacients, :through => :mentors
  has_many :cards

  validates_presence_of :name
  validates_length_of :name, :maximum => 100

  def manager
    user
  end

  def unassigned_cards
    cards.where(:pacient_id => nil)
  end
end
