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

    it "cannt be after the expiration" do
      @card.expiration = Date.today
      Timecop.travel 1.day
      @card.validity = Date.today
      @card.should_not be_valid
    end
  end

  describe "expiration" do
    before(:each) do
      Timecop.travel(2013,5,31)
      @card = Card.make!
    end

    it "should not have expiration set by default" do
      @card.expiration.should be_nil
    end

    it "should not be expired if expiration is not set" do
      @card.should_not be_expired
    end

    it "should set expiration when setting validity" do
      @card.validity = Date.today
      @card.save!

      @card.expiration.should_not be_nil
    end

    it "should have a default expiration of 1 year" do
      @card.validity = Date.today
      @card.save!

      @card.expiration.should eq(@card.validity + 1.year)
    end

    it "should be reset when the validity is set to nil" do
      @card.validity = Date.today
      @card.save!

      @card.expiration.should_not be_nil

      @card.validity = nil
      @card.save!

      @card.expiration.should be_nil
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
