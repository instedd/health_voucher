require 'spec_helper'

describe Transaction::Processor do
  before(:each) do
    @service1 = Service.make!
    @service2 = Service.make!(:secondary)
    @service3 = Service.make!

    @provider = Provider.make!

    @card = Card.make!(:with_vouchers)
    @patient = Patient.make! current_card: @card

    @auth1 = Authorization.make! provider: @provider, service: @service1, card: @card
    @auth2 = Authorization.make! provider: @provider, service: @service2, card: @card

    @voucher1 = @card.primary_services.first
    @voucher2 = @card.secondary_services.first
  end

  describe "validate" do
    it "should find a valid pending authorization" do
      @processor = Transaction::Processor.new(@service1, @voucher1)

      @processor.validate.should be_true
      @processor.auth.should eq(@auth1)
    end

    it "should validate that a pending authorization exists" do
      @processor = Transaction::Processor.new(@service3, @voucher1)

      @processor.validate.should be_false
      @processor.error.should eq(:not_authorized)
    end

    it "should validate that the voucher is not already used" do
      @voucher1.use!

      @processor = Transaction::Processor.new(@service1, @voucher1)

      @processor.validate.should be_false
      @processor.error.should eq(:voucher_already_used)
    end

    it "should validate that the voucher is primary if the service is primary" do
      @processor = Transaction::Processor.new(@service1, @voucher2)

      @processor.validate.should be_false
      @processor.error.should eq(:voucher_not_primary)
    end

    it "should validate that the voucher is secondary if the service is secondary" do
      @processor = Transaction::Processor.new(@service2, @voucher1)

      @processor.validate.should be_false
      @processor.error.should eq(:voucher_not_secondary)
    end
  end

  describe "confirm" do
    before(:each) do
      @processor = Transaction::Processor.new(@service1, @voucher1)
      @processor.validate.should be_true
    end

    it "should return a string" do
      @processor.confirm.should be_a(String)
    end

    it "should mark the voucher as used" do
      @processor.confirm

      @voucher1.should be_used
    end

    it "should create a transaction for the authorization" do
      @processor.confirm

      @auth1.transaction.should_not be_nil
    end
  end
end
