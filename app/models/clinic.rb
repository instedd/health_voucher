class Clinic < ActiveRecord::Base
  attr_accessible :name

  belongs_to :site

  has_many :clinic_services, :dependent => :destroy
  has_many :services, :through => :clinic_services
  has_many :providers

  validates_presence_of :name
  validates_length_of :name, :maximum => 80
  validates_uniqueness_of :name, :scope => :site_id, :case_sensitive => false

  before_destroy :check_no_providers

  def all_clinic_services
    Service.order(:code).map do |service|
      clinic_services.where(:service_id => service.id).first_or_initialize
    end
  end

  def enabled_clinic_services
    clinic_services.where(:enabled => true)
  end

  def provides_service?(service)
    enabled_clinic_services.include?(service)
  end

  private

  def check_no_providers
    if providers.count > 0
      errors[:base] << "The clinic has providers registered"
      false
    else
      true
    end
  end
end
