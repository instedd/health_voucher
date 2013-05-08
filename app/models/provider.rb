class Provider < ActiveRecord::Base
  attr_accessible :code, :enabled, :name

  belongs_to :clinic

  has_many :transactions

  validates_presence_of :name, :code, :clinic
  validates_uniqueness_of :code
  validates_format_of :code, :with => /\A[0-9]+\z/
  validates_length_of :code, :maximum => 3
  validates_length_of :name, :maximum => 100

  before_destroy :check_no_transactions

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
