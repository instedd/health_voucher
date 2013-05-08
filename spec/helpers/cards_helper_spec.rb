require 'spec_helper'

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
end
