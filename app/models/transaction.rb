class Transaction < ActiveRecord::Base
  extend Enumerize

  enumerize :status, in: [:unpaid, :pending, :suspicious, :rejected, :paid],
    default: :unpaid, predicates: true

  attr_accessible :comment

  belongs_to :provider
  belongs_to :voucher
  belongs_to :service
  belongs_to :authorization

  validates_presence_of :provider, :voucher, :service

  # Status changes allowed:
  #
  # Unpaid => Pending or Rejected (To set paid you have to set paid the full
  # statament)
  # 
  # Pending => Unpaid or Rejected
  #
  # Suspicious => Unpaid or Rejected
  #
  # Rejected => Pending or Unpaid
  #
  # Paid => no change allowed, flag unpaid the full statement before
end
