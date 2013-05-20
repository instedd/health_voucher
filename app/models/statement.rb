class Statement < ActiveRecord::Base
  extend Enumerize

  attr_accessible :status, :until

  belongs_to :clinic
  
  has_many :transactions, :dependent => :nullify

  validates_presence_of :clinic
  validates_presence_of :until

  scope :for_listing, includes(:clinic => :site, :transactions => [])

  paginates_per 15

  def site
    clinic.site
  end
end
