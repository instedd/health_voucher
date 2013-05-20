class Transaction < ActiveRecord::Base
  extend Enumerize

  enumerize :status, in: [:unpaid, :pending, :suspicious, :rejected, :paid],
    default: :unpaid, predicates: true

  attr_accessible :comment

  belongs_to :voucher
  belongs_to :authorization
  belongs_to :statement

  validates_presence_of :voucher, :authorization
  validates_length_of :comment, :maximum => 200

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

  def training?
    authorization.training?
  end

  def update_status status, comments
    if paid?
      errors[:base] << "Transaction status cannot be changed from paid without cancelling the statement first"
    end

    self.status = status
    self.comment = comments
    save
  end
end
