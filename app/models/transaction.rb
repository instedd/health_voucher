class Transaction < ActiveRecord::Base
  extend Enumerize

  enumerize :status, in: [:unpaid, :pending, :suspicious, :rejected, :paid],
    default: :unpaid, predicates: true

  attr_accessible :comment

  belongs_to :voucher
  belongs_to :authorization
  belongs_to :statement

  validates_presence_of :voucher, :authorization

  scope :for_listing, includes(:authorization => [:service, :card => :patient, :provider => :clinic])

  paginates_per 15

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
  
  def provider
    authorization.provider
  end

  def clinic
    provider.clinic
  end

  def service
    authorization.service
  end

  def card
    authorization.card
  end

  def patient
    card.patient
  end
end
