class Clinic < ActiveRecord::Base
  attr_accessible :name

  belongs_to :site

  has_many :clinic_services, :dependent => :destroy
  has_many :services, :through => :clinic_services
  has_many :providers
end
