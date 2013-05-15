require 'spec_helper'

describe Clinic do
  describe "destroy" do
    it "should not delete clinics with providers" do
      @clinic = Clinic.make!
      @provider = Provider.make! clinic: @clinic

      @clinic.destroy
      @clinic.should_not be_destroyed
    end
  end

  describe "provides service?" do
    it "should return true if the clinic provides the service" do
      @clinic = Clinic.make!
      @service = Service.make!

      @clinic.provides_service?(@service).should be_false

      @clinic.clinic_services.create! service: @service, enabled: true, cost: 1

      @clinic.provides_service?(@service).should be_true
    end
  end
end
