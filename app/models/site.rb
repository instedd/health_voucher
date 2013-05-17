class Site < ActiveRecord::Base
  attr_accessible :name, :training

  belongs_to :user
  has_many :clinics, :dependent => :destroy
  has_many :mentors, :dependent => :destroy
  has_many :patients, :through => :mentors
  has_many :cards, :dependent => :nullify
  has_many :providers, :through => :clinics

  validates_presence_of :name
  validates_length_of :name, :maximum => 100

  def manager
    user
  end

  def unassigned_cards
    cards.where(:patient_id => nil).order(:serial_number)
  end
end
