class Card < ActiveRecord::Base
  attr_accessible :serial_number
  has_many :vouchers, :dependent => :destroy
  validates :serial_number, :uniqueness => true
  LengthSerialNumber = 6
end
