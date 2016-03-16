require 'rails_helper'

describe Authorization do
  describe "training" do
    before(:each) do
      @service = Service.make!

      @site = Site.make! training: false
      @training_site = Site.make! training: true

      @card = Card.make!(:with_vouchers) 
      @provider = Provider.make!

      @auth = Authorization.make! card: @card, provider: @provider, service: @service
    end

    it "should be false by default" do
      @auth.should_not be_training
    end

    it "should be true if the card belongs to a training site" do
      @card.update_attribute :site, @training_site

      @auth.should be_training
    end

    it "should be true if the provider belongs to a training site" do
      @provider.clinic.update_attribute :site, @training_site

      @auth.should be_training
    end
  end
end
