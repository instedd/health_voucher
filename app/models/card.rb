class Card < ActiveRecord::Base
  LengthSerialNumber = 6

  attr_accessible :serial_number

  has_many :vouchers, :dependent => :destroy

  belongs_to :pacient
  belongs_to :site
  belongs_to :batch

  validates :serial_number, :uniqueness => true
  validates_presence_of :serial_number
end
