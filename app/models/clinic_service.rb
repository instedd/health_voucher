class ClinicService < ActiveRecord::Base
  attr_accessible :service, :cost, :enabled

  belongs_to :clinic
  belongs_to :service
end
