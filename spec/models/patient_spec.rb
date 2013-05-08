require 'spec_helper'

describe Patient do
  describe "AGEP ID validation" do
    it "should validate 7 digits IDs" do
      Patient.new(agep_id: '1234567').should be_valid
    end

    it "should validate 10 digits IDs" do
      Patient.new(agep_id: '1234567890').should be_valid
    end

    it "should reject non-digit IDs" do
      Patient.new(agep_id: 'ABCDEFG').should_not be_valid
    end

    it "should reject IDs of length other than 7 or 10" do
      (0..15).each do |length|
        unless length == 7 || length == 10
          Patient.new(agep_id: '1'*length).should_not be_valid
        end
      end
    end
  end

  describe "current card" do
    before(:each) do
      @card = Card.make!
      @patient = Patient.make!
    end

    it "should validate unassigned cards" do
      @patient.current_card = @card
      @patient.should be_valid
    end

    it "should validate cards from the patient" do
      @card.patient = @patient
      @card.save!

      @patient.reload.current_card = @card
      @patient.should be_valid
    end

    it "should not validate cards belonging to other patients" do
      @other = Patient.make!
      @card.patient = @other
      @card.save!

      @patient.current_card = @card
      @patient.should_not be_valid
    end

    it "should set the card's patient if the card was unassigned" do
      @patient.current_card = @card
      @patient.save!

      @card.reload.patient.should eq(@patient)
    end
  end
end
