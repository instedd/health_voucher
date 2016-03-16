class ClinicService < ActiveRecord::Base
  belongs_to :clinic
  belongs_to :service

  validates_numericality_of :cost, :allow_nil => true, :greater_than_or_equal_to => 0
end
