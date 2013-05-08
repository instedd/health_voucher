require 'spec_helper'

describe Pacient do
  describe "AGEP ID validation" do
    it "should validate 7 digits IDs" do
      Pacient.new(agep_id: '1234567').should be_valid
    end

    it "should validate 10 digits IDs" do
      Pacient.new(agep_id: '1234567890').should be_valid
    end

    it "should reject non-digit IDs" do
      Pacient.new(agep_id: 'ABCDEFG').should_not be_valid
    end

    it "should reject IDs of length other than 7 or 10" do
      (0..15).each do |length|
        unless length == 7 || length == 10
          Pacient.new(agep_id: '1'*length).should_not be_valid
        end
      end
    end
  end

  describe "current card" do
    before(:each) do
      @card = Card.make!
      @pacient = Pacient.make!
    end

    it "should validate unassigned cards" do
      @pacient.current_card = @card
      @pacient.should be_valid
    end

    it "should validate cards from the pacient" do
      @card.pacient = @pacient
      @card.save!

      @pacient.reload.current_card = @card
      @pacient.should be_valid
    end

    it "should not validate cards belonging to other pacients" do
      @other = Pacient.make!
      @card.pacient = @other
      @card.save!

      @pacient.current_card = @card
      @pacient.should_not be_valid
    end

    it "should set the card's pacient if the card was unassigned" do
      @pacient.current_card = @card
      @pacient.save!

      @card.reload.pacient.should eq(@pacient)
    end
  end
end
