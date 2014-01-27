require 'spec_helper'

describe Message::Processor do
  before(:each) do
    @service = Service.make!
    @other_service = Service.make!

    @clinic = Clinic.make!
    @cs = ClinicService.make! clinic: @clinic, service: @service

    @provider = Provider.make! clinic: @clinic

    @card = Card.make!(:with_vouchers)
    @patient = Patient.make! current_card: @card

    @from = "555"
  end

  describe "with invalid message" do
    it "should save an unknown message with error" do
      @processor = Message::Processor.new "garbage", @from
      result = @processor.process
      message = @processor.message.reload

      message.from.should == @from
      message.body.should == "garbage"
      message.should be_error
      message.should be_unknown
      message.response.should == result
    end
  end

  describe "with valid authorization message" do
    before(:each) do
      @body = "#{@provider.code}+#{@patient.agep_id}+#{@card.full_serial_number}+#{@service.code}"
      @processor = Message::Processor.new @body, @from
    end

    it "should make the authorization" do
      lambda do
        @processor.process
      end.should change(Authorization, :count).by(1)
    end

    it "should link the message to the authorization" do
      @processor.process
      message = @processor.message.reload
      message.authorizations.count.should == 1
    end

    it "should save a successful authorization message" do
      @processor.process
      message = @processor.message.reload

      message.from.should == @from
      message.body.should == @body
      message.should be_authorization
      message.should be_success
      message.response.should_not be_blank
    end
  end

  describe "with invalid authorization message" do
    before(:each) do
      @body = "#{@provider.code}+#{@patient.agep_id}+#{@card.full_serial_number}+#{@other_service.code}"
      @processor = Message::Processor.new @body, @from
    end

    it "should not make the authorization" do
      lambda do
        @processor.process
      end.should_not change(Authorization, :count)
    end

    it "should save a failed authorization message" do
      @processor.process
      message = @processor.message.reload

      message.from.should == @from
      message.body.should == @body
      message.should be_authorization
      message.should be_failure
      message.response.should_not be_blank
    end
  end

  describe "confirmations" do
    before(:each) do
      @auth = Authorization.make! provider: @provider, service: @service, card: @card
      @voucher = @card.primary_services.first
    end

    describe "with valid message" do
      before(:each) do
        @body = "#{@service.code}+#{@voucher.code}"
        @processor = Message::Processor.new @body, @from
      end

      it "should register the transaction" do
        lambda do
          @processor.process
        end.should change(Transaction, :count).by(1)
        @auth.reload.transaction.should_not be_nil
      end

      it "should link the message to the transaction" do
        @processor.process
        message = @processor.message.reload
        message.transaction.should_not be_nil
      end

      it "should save a successful confirmation message" do
        @processor.process
        message = @processor.message.reload

        message.from.should == @from
        message.body.should == @body
        message.should be_confirmation
        message.should be_success
        message.response.should_not be_blank
      end
    end

    describe "with invalid message" do
      before(:each) do
        @body = "#{@other_service.code}+#{@voucher.code}"
        @processor = Message::Processor.new @body, @from
      end

      it "should not register the transaction" do
        lambda do
          @processor.process
        end.should_not change(Transaction, :count)
        @auth.reload.transaction.should be_nil
      end

      it "should save a failed confirmation message" do
        @processor.process
        message = @processor.message.reload

        message.from.should == @from
        message.body.should == @body
        message.should be_confirmation
        message.should be_failure
        message.response.should_not be_blank
      end
    end
  end
end
