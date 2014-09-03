class Transaction < ActiveRecord::Base
  extend Enumerize

  enumerize :status, in: [:unpaid, :pending, :suspicious, :rejected, :paid],
    default: :unpaid, predicates: true

  attr_accessible :comment

  belongs_to :voucher
  belongs_to :authorization
  belongs_to :statement
  belongs_to :message

  validates_presence_of :voucher, :authorization
  validates_length_of :comment, :maximum => 200

  scope :for_listing, includes(:authorization => [:service, :card => {:patient => {:mentor => :site}}, :provider => :clinic])

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

  def service_id
    authorization.service_id
  end

  def card
    authorization.card
  end

  def patient
    card.patient
  end

  def updatable?
    !training? && statement_id.nil?
  end

  def update_status status, comments
    if training?
      errors[:base] << "Can't change status for training transactions"
    elsif statement_id.present?
      errors[:base] << "Transaction status cannot be changed when the transaction is in a statement"
    end
    return if errors.any?

    self.status = status
    self.comment = comments
    save
  end
end
