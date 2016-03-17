require 'rails_helper'

describe CardsHelper do
  describe "cards availability" do
    before(:each) do
      @batch = Batch.make!
    end

    it "returns a hash map" do
      helper.cards_availability([]).should be_a(Hash)
    end

    it "has the required data" do
      result = helper.cards_availability(Batch.all)
      result.should include(@batch.id)
      result[@batch.id].should be_a(Hash)
      result[@batch.id].should include(:first_serial_number)
      result[@batch.id].should include(:quantity)
    end
  end

  describe "card validity & expiration" do
    before(:each) do
      @card = Card.make!
    end

    it "returns empty string when no date" do
      expect(helper.card_validity(@card)).to be_empty
      expect(helper.card_expiration(@card)).to be_empty
    end

    it "returns the date formatted as string" do
      @card.validity = Date.new(2016,3,17)
      @card.expiration = Date.new(2016,3,18)
      expect(helper.card_validity(@card)).to eq('03/17/2016')
      expect(helper.card_expiration(@card)).to eq('03/18/2016')
    end
  end
end
