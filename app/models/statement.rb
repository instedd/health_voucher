class Statement < ActiveRecord::Base
  extend Enumerize

  attr_accessible :status, :until

  enumerize :status, in: [:unpaid, :paid], 
    :default => :unpaid, :predicates => true

  belongs_to :clinic
  
  has_many :transactions, :dependent => :nullify

  validates_presence_of :clinic
  validates_presence_of :until

  scope :for_listing, includes(:clinic => :site, :transactions => [])

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
end
