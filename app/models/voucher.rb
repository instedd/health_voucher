class Voucher < ActiveRecord::Base
  extend Enumerize

  VOUCHER_CODE_LENGTH = 12

  attr_accessible :service_type, :code

  enumerize :service_type, in: [:primary, :secondary, :any], default: :any, predicates: true

  belongs_to :card

  validates_presence_of :card
  validates_uniqueness_of :code
  validates :code, :code => { :length => VOUCHER_CODE_LENGTH }

  def self.valid_voucher_code?(code)
    code.length == VOUCHER_CODE_LENGTH &&
      Card::Code.check(code)
  end

  def use!
    update_attribute :used, true
  end
end
