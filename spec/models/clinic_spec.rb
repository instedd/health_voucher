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
end
