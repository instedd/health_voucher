require 'spec_helper'

describe Authorization::Processor do
  before(:each) do
    @service1 = Service.make!
    @service2 = Service.make!(:secondary)
    @card = Card.make!(:with_vouchers)
    @clinic = Clinic.make!
    @cs1 = ClinicService.make! clinic: @clinic, service: @service1
    @cs2 = ClinicService.make! clinic: @clinic, service: @service2
    @provider = Provider.make! clinic: @clinic
    @patient = Patient.make! current_card: @card

    @processor = Authorization::Processor.new(@provider, @patient, @card)
  end
  
  describe "pre validation" do
    it "should pass with valid conditions" do
      @processor.validate.should be_true
    end

    it "should validate that the provider is enabled" do
      @provider.update_attribute :enabled, false
      
      @processor.validate.should be_false
      @processor.error.should eq(:provider_disabled)
    end

    it "should validate that the card belongs to the patient" do
      @patient.update_attribute :current_card, nil
      @card.update_attribute :patient, Patient.make!

      @processor.validate.should be_false
      @processor.error.should eq(:card_agep_id_mismatch)
    end

    it "should validate that the card is not marked as stolen" do
      @card.report_lost!

      @processor.validate.should be_false
      @processor.error.should eq(:card_stolen)
    end

    it "should validate that the card is not expired" do
      @card.update_attribute :validity, (1.year + 1.day).ago

      @processor.validate.should be_false
      @processor.error.should eq(:card_expired)
    end
  end

  describe "current pending authorizations for clinic" do
    before(:each) do
      @auth1 = Authorization.make! card: @card, provider: @provider, service: @service1  
      @auth2 = Authorization.make! card: @card, provider: @provider, service: @service2  
    end

    it "should return authorizations made today from the card for the given clinic" do
      @processor.current_pending_authorizations_for(@clinic).should include(@auth1)
      @processor.current_pending_authorizations_for(@clinic).should include(@auth2)
    end

    it "should not return authorizations made for another clinic" do
      @auth3 = Authorization.make! card: @card, provider: Provider.make!, service: @service1

      @processor.current_pending_authorizations_for(@clinic).should_not include(@auth3)
    end

    it "should not return authorizations made at another day" do
      Timecop.travel 1.day

      @processor.current_pending_authorizations_for(@clinic).should be_empty
    end

    it "should not return confirmed authorizations" do
      @txn = Transaction.make! authorization: @auth1, provider: @auth1.provider, 
        voucher: @card.vouchers.first, service: @auth1.service

      @processor.current_pending_authorizations_for(@clinic).should_not include(@auth1)
      @processor.current_pending_authorizations_for(@clinic).should include(@auth2)
    end
  end

  describe "count available vouchers" do
    it "should return all available vouchers if there are no authorizations for today" do
      @processor.count_available_vouchers(@clinic).should be_a(Hash)
      @processor.count_available_vouchers(@clinic)[:primary].should eq(6)
      @processor.count_available_vouchers(@clinic)[:secondary].should eq(7)
    end

    it "should not count used vouchers" do
      @card.vouchers.where(:service_type => :primary).first.update_attribute :used, true
      @card.vouchers.where(:service_type => :secondary).first.update_attribute :used, true

      @processor.count_available_vouchers(@clinic)[:primary].should eq(5)
      @processor.count_available_vouchers(@clinic)[:secondary].should eq(6)
    end
    
    it "should consider pending authorizations for the same clinic" do
      @auth1 = Authorization.make! card: @card, provider: @provider, service: @service1
      @auth2 = Authorization.make! card: @card, provider: @provider, service: @service2

      @processor.count_available_vouchers(@clinic)[:primary].should eq(5)
      @processor.count_available_vouchers(@clinic)[:secondary].should eq(6)
    end

    it "should ignore pending authorizations for another clinic" do
      @auth1 = Authorization.make! card: @card, provider: Provider.make!, service: @service1

      @processor.count_available_vouchers(@clinic)[:primary].should eq(6)
      @processor.count_available_vouchers(@clinic)[:secondary].should eq(7)
    end
  end

  describe "add services" do
    it "should validate adding available services" do
      @processor.add_services([@service1, @service2]).should be_true, @processor.error_message
    end
  end
end
