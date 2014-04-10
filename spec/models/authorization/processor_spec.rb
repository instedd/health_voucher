require 'spec_helper'

describe Authorization::Processor do
  before(:each) do
    @service1 = Service.make!
    @service2 = Service.make!(:secondary)
    @service3 = Service.make!

    @clinic = Clinic.make!
    @cs1 = ClinicService.make! clinic: @clinic, service: @service1
    @cs2 = ClinicService.make! clinic: @clinic, service: @service2
    @cs3 = ClinicService.make! clinic: @clinic, service: @service3

    @provider = Provider.make! clinic: @clinic

    @card = Card.make!(:with_vouchers)
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
      @txn = Transaction.make! authorization: @auth1, voucher: @card.vouchers.first

      @processor.current_pending_authorizations_for(@clinic).should_not include(@auth1)
      @processor.current_pending_authorizations_for(@clinic).should include(@auth2)
    end

    it "should return authorizations made at the beginning of the day" do
      Timecop.travel(Time.zone.now.beginning_of_day) do
        @auth3 = Authorization.make! card: @card, provider: @provider, service: @service3
      end

      Timecop.travel(Time.zone.now.end_of_day.ago(1.minute)) do
        @processor.current_pending_authorizations_for(@clinic).should include(@auth3, @auth2, @auth1)
      end
    end
  end

  describe "count available vouchers" do
    it "should return all available vouchers if there are no authorizations for today" do
      @processor.count_available_vouchers(@clinic).should be_a(Hash)
      @processor.count_available_vouchers(@clinic)[:primary].should eq(Card::PRIMARY_SERVICES)
      @processor.count_available_vouchers(@clinic)[:secondary].should eq(Card::SECONDARY_SERVICES)
      @processor.count_available_vouchers(@clinic)[:any].should eq(0)
    end

    it "should not count used vouchers" do
      @card.vouchers.where(:service_type => :primary).first.update_attribute :used, true
      @card.vouchers.where(:service_type => :secondary).first.update_attribute :used, true

      @processor.count_available_vouchers(@clinic)[:primary].should eq(Card::PRIMARY_SERVICES - 1)
      @processor.count_available_vouchers(@clinic)[:secondary].should eq(Card::SECONDARY_SERVICES - 1)
      @processor.count_available_vouchers(@clinic)[:any].should eq(0)
    end
    
    it "should consider pending authorizations for the same clinic" do
      @auth1 = Authorization.make! card: @card, provider: @provider, service: @service1
      @auth2 = Authorization.make! card: @card, provider: @provider, service: @service2

      @processor.count_available_vouchers(@clinic)[:primary].should eq(Card::PRIMARY_SERVICES - 1)
      @processor.count_available_vouchers(@clinic)[:secondary].should eq(Card::SECONDARY_SERVICES - 1)
      @processor.count_available_vouchers(@clinic)[:any].should eq(0)
    end

    it "should ignore pending authorizations for another clinic" do
      @auth1 = Authorization.make! card: @card, provider: Provider.make!, service: @service1

      @processor.count_available_vouchers(@clinic)[:primary].should eq(Card::PRIMARY_SERVICES)
      @processor.count_available_vouchers(@clinic)[:secondary].should eq(Card::SECONDARY_SERVICES)
      @processor.count_available_vouchers(@clinic)[:any].should eq(0)
    end
  end

  describe "add services" do
    it "should validate adding available services" do
      @processor.add_services([@service1, @service2]).should be_true
      @processor.services.should eq([@service1, @service2])
    end

    it "should ignore duplicate services" do
      @processor.add_services([@service1, @service1]).should be_true
      @processor.services.should eq([@service1])
    end

    it "should add previously authorized services" do
      @auth1 = Authorization.make! card: @card, provider: @provider, service: @service1

      @processor.add_services([@service1]).should be_true
      @processor.services.should eq([@service1])
    end

    it "should not authorize services the clinic's provider does not provide" do
      @service3 = Service.make!

      @processor.add_services([@service3]).should be_false
      @processor.error.should eq(:service_not_provided)
    end
    
    it "should not authorize primary services when no primary vouchers are available" do
      @card.primary_services.each do |voucher|
        voucher.update_attribute :used, true
      end

      @processor.add_services([@service1]).should be_false
      @processor.error.should eq(:no_primary_vouchers)
    end

    it "should not authorize secondary services when no secondary vouchers are available" do
      @card.secondary_services.each do |voucher|
        voucher.update_attribute :used, true
      end

      @processor.add_services([@service2]).should be_false
      @processor.error.should eq(:no_secondary_vouchers)
    end

    it "should count pending authorizations as used vouchers" do
      @card.primary_services.take(Card::PRIMARY_SERVICES - 1).each do |voucher|
        voucher.update_attribute :used, true
      end
      @auth1 = Authorization.make! card: @card, provider: @provider, service: @service1

      @processor.add_services([@service3]).should be_false
      @processor.error.should eq(:no_primary_vouchers)
    end

    it "should not authorize more than max_daily_authorizations" do
      @processor.stubs(:max_daily_authorizations).returns(1)

      @processor.add_services([@service1, @service2]).should be_false
      @processor.error.should eq(:agep_id_authorization_limit)
    end

    it "should count pending authorizations towards max daily authorizations" do
      @processor.stubs(:max_daily_authorizations).returns(1)

      @auth1 = Authorization.make! card: @card, provider: @provider, service: @service1

      @processor.add_services([@service2]).should be_false
      @processor.error.should eq(:agep_id_authorization_limit)
    end

    it "should count confirmed authorizations (regardless of clinic) towards max daily authorizations" do
      @processor.stubs(:max_daily_authorizations).returns(1)

      @auth = Authorization.make! card: @card, provider: Provider.make!, service: @service1
      @txn = Transaction.make! voucher: @card.primary_services.first, authorization: @auth

      @processor.add_services([@service1]).should be_false
      @processor.error.should eq(:agep_id_authorization_limit)
    end

    it "should not count pending authorizations for another clinic towards max daily authorizations" do
      @processor.stubs(:max_daily_authorizations).returns(1)

      @auth = Authorization.make! card: @card, provider: Provider.make!, service: @service1

      @processor.add_services([@service1]).should be_true
    end
  end

  describe "authorize" do
    before(:each) do
      @processor.validate.should be_true
      @processor.add_services([@service1, @service2]).should be_true
    end

    it "should return a success text message" do
      @processor.authorize.should be_a(String)
    end

    it "should create authorizations for the given services" do
      lambda do
        @processor.authorize
      end.should change(Authorization, :count).by(2)

      authorizations = @card.authorizations.today.by_clinic(@clinic)
      authorizations.count.should eq(2)
      authorizations.map(&:service).should include(@service1)
      authorizations.map(&:service).should include(@service2)
    end

    it "should destroy any today's pending authorizations for another clinic" do
      @another_provider = Provider.make!
      @another_auth = Authorization.make! card: @card, 
        provider: @another_provider, service: @service3

      @card.authorizations.today.count.should eq(1)

      @processor.authorize

      Authorization.where(:id => @another_auth.id).should be_empty
      @card.authorizations.today.count.should eq(2)
    end

    it "should not set card's validity if already initialized" do
      Timecop.freeze(Date.today)

      @card.update_attribute :validity, Date.yesterday
      lambda do
        @processor.authorize
      end.should_not change(@card, :validity)
    end

    it "should set validity date on the card if it was nil" do
      Timecop.freeze

      @card.validity.should be_nil

      @processor.authorize

      @card.validity.should_not be_nil
      @card.validity.should eq(Date.today)
    end

    it "should retain previous authorizations for the same clinic" do
      @auth3 = Authorization.make! card: @card, provider: @provider, service: @service3

      lambda do
        @processor.authorize
      end.should change(Authorization, :count).by(2)

      @card.authorizations.should include(@auth3)
    end

    it "should not create a second authorization for a previously authorized service" do
      @auth1 = Authorization.make! card: @card, provider: @provider, service: @service1

      lambda do
        @processor.authorize
      end.should change(Authorization, :count).by(1)

      @card.authorizations.should include(@auth1)
    end

    it "should not destroy confirmed authorizations" do
      @another_provider = Provider.make!
      @another_auth = Authorization.make! card: @card, 
        provider: @another_provider, service: @service1
      @txn = Transaction.make! authorization: @another_auth, voucher: @card.primary_services.first

      lambda do
        @processor.authorize
      end.should change(Authorization, :count).by(2)

      Authorization.where(:id => @another_auth.id).first.should eq(@another_auth)
    end
  end

  describe "training" do
    before(:each) do
      @training_site = Site.make! training: true
    end

    it "should be false by default" do
      @processor.should_not be_training
    end

    it "should be true if the card belongs to a training site" do
      @card.update_attribute :site, @training_site

      @processor.should be_training
    end

    it "should be true if the provider belongs to a training site" do
      @provider.clinic.update_attribute :site, @training_site

      @processor.should be_training
    end
  end

  describe "with any service voucher cards" do
    before(:each) do
      @card = Card.make!(:with_any_vouchers)
      @patient.update_attribute :current_card, @card

      @processor = Authorization::Processor.new(@provider, @patient, @card)
    end

    describe "count available vouchers" do
      it "should return all available vouchers if there are no authorizations for today" do
        @processor.count_available_vouchers(@clinic).should be_a(Hash)
        @processor.count_available_vouchers(@clinic)[:primary].should eq(0)
        @processor.count_available_vouchers(@clinic)[:secondary].should eq(0)
        @processor.count_available_vouchers(@clinic)[:any].should eq(Card::ANY_SERVICES)
      end

      it "should not count used vouchers" do
        @card.vouchers.where(:service_type => :any).first.update_attribute :used, true

        @processor.count_available_vouchers(@clinic)[:primary].should eq(0)
        @processor.count_available_vouchers(@clinic)[:secondary].should eq(0)
        @processor.count_available_vouchers(@clinic)[:any].should eq(Card::ANY_SERVICES - 1)
      end
      
      it "should consider pending authorizations for the same clinic" do
        @auth1 = Authorization.make! card: @card, provider: @provider, service: @service1

        @processor.count_available_vouchers(@clinic)[:primary].should eq(0)
        @processor.count_available_vouchers(@clinic)[:secondary].should eq(0)
        @processor.count_available_vouchers(@clinic)[:any].should eq(Card::ANY_SERVICES - 1)
      end

      it "should ignore pending authorizations for another clinic" do
        @auth1 = Authorization.make! card: @card, provider: Provider.make!, service: @service1

        @processor.count_available_vouchers(@clinic)[:primary].should eq(0)
        @processor.count_available_vouchers(@clinic)[:secondary].should eq(0)
        @processor.count_available_vouchers(@clinic)[:any].should eq(Card::ANY_SERVICES)
      end
    end

    describe "add services" do
      it "should validate adding available services" do
        @processor.add_services([@service1, @service2]).should be_true
        @processor.services.should eq([@service1, @service2])
      end

      it "should not authorize primary services when no vouchers are available" do
        @card.vouchers.each do |voucher|
          voucher.update_attribute :used, true
        end

        @processor.add_services([@service1]).should be_false
        @processor.error.should eq(:no_available_vouchers)
      end

      it "should not authorize secondary services when no vouchers are available" do
        @card.vouchers.each do |voucher|
          voucher.update_attribute :used, true
        end

        @processor.add_services([@service2]).should be_false
        @processor.error.should eq(:no_available_vouchers)
      end

      it "should count pending authorizations as used vouchers" do
        @card.any_services.take(Card::ANY_SERVICES - 1).each do |voucher|
          voucher.update_attribute :used, true
        end
        @auth1 = Authorization.make! card: @card, provider: @provider, service: @service1

        @processor.add_services([@service3]).should be_false
        @processor.error.should eq(:no_available_vouchers)
      end
    end
  end
end

