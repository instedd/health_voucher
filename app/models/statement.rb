class Statement < ActiveRecord::Base
  attr_accessible :status, :until
  belongs_to :clinic
  has_many :transactions
end
