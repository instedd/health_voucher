class Statement < ActiveRecord::Base
  extend Enumerize

  attr_accessible :status, :until

  enumerize :status, in: [:unpaid, :paid], 
    :default => :unpaid, :predicates => true

  belongs_to :clinic
  
  # this needs to be before has_many :dependent
  before_destroy :mark_unpaid_all_transactions

  has_many :transactions, :dependent => :nullify

  validates_presence_of :clinic
  validates_presence_of :until

  scope :for_listing, includes(:clinic => :site).joins(:transactions).group('statements.id').
    select(['statements.*', 'COUNT(transactions.id) AS txn_count', 
            'MAX(transactions.created_at) AS txn_to', 'MIN(transactions.created_at) AS txn_from'])

  paginates_per 15

  def site
    clinic.site
  end

  def compute_total
    self.total = transactions.
      joins(:authorization => {
        :provider => {:clinic => :clinic_services}
      }).
      where('clinic_services.service_id = authorizations.service_id').
      sum('clinic_services.cost')
  end

  def toggle_status!
    self.class.transaction do
      if paid?
        update_attribute :status, :unpaid
        transactions.update_all :status => :unpaid
      else
        update_attribute :status, :paid
        transactions.update_all :status => :paid
      end
    end 
  end

  private

  def mark_unpaid_all_transactions
    transactions.update_all :status => :unpaid
    true
  end
end

