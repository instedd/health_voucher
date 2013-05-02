class Voucher < ActiveRecord::Base
  extend Enumerize

  VOUCHER_CODE_LENGTH = 12

  enumerize :service_type, in: [:primary, :secondary], default: :primary, predicates: true

  belongs_to :card

  validates_presence_of :card
  validates_uniqueness_of :code
  validates :code, :code => { :length => VOUCHER_CODE_LENGTH }
end
