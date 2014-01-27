require 'spec_helper'

describe Card do
  describe "validity" do
    before(:each) do
      Timecop.travel(2013,5,31)
      @card = Card.make!
    end

    it "nil should be valid" do
      @card.validity = nil
      @card.should be_valid
    end

    it "should accept a Date" do
      @card.validity = Date.today
      @card.should be_valid
    end

    it "should accept a Time" do
      @card.validity = Time.current
      @card.should be_valid
    end

    it "should parse a string" do
      @card.validity = "5/31/2013"
      @card.should be_valid
      @card.validity.should == Date.new(2013,5,31)
    end

    it "cannot be in the future" do
      @card.validity = Date.tomorrow
      @card.should_not be_valid
      @card.errors[:validity].should_not be_empty
    end

    it "cannot be before the card creation time" do
      @card.validity = @card.created_at.yesterday
      @card.should_not be_valid
    end
  end

  describe "used?" do
    before(:each) do
      @card = Card.make!(:with_vouchers)
    end

    it "should be false if no vouchers are used" do
      @card.should_not be_used
      @card.validity = Date.today
      @card.should_not be_used
    end

    it "should be true if any vouchers are used" do
      @card.vouchers.first.update_attribute :used, true
      @card.should be_used
    end

    it "should be true if it has authorizations" do
      @provider = Provider.make!
      @service = Service.make!
      @card.authorizations.create! provider: @provider, service: @service
      @card.should be_used
    end
  end
end
