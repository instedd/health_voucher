class ClinicService < ActiveRecord::Base
  belongs_to :clinic
  belongs_to :service
  attr_accessible :cost, :enabled
end
