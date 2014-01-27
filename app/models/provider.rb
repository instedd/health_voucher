class Provider < ActiveRecord::Base
  PROVIDER_CODE_LENGTH = 4

  attr_accessible :code, :name
  attr_accessible :clinic_id, :code, :name, :as => :creator

  belongs_to :clinic
  has_one :site, :through => :clinic

  has_many :authorizations
  has_many :transactions, :through => :authorizations

  validates_presence_of :name, :clinic
  validates_uniqueness_of :code
  validates_format_of :code, :with => /\A[0-9]{#{PROVIDER_CODE_LENGTH}}\z/
  validates_length_of :name, :maximum => 100

  before_destroy :check_no_transactions

  def disabled?
    !enabled?
  end

  private

  def check_no_transactions
    if transactions.count > 0
      errors[:base] << "The provider has registered transactions"
      false
    else
      true
    end
  end
end
