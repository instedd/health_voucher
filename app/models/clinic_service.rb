class ClinicService < ActiveRecord::Base
  attr_accessible :cost, :enabled

  belongs_to :clinic
  belongs_to :service
end
