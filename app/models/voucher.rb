class Voucher < ActiveRecord::Base
  belongs_to :card
  attr_accessible :code, :panel
  validates :code, :uniqueness => true
  LengthVoucherNumber = 12
end
