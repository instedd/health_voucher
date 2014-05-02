require 'spec_helper'

describe Patient do
  describe "AGEP ID validation" do
    it "should validate 7 digits IDs" do
      Patient.make(agep_id: '1234567').should be_valid
    end

    it "should validate 9 digits IDs" do
      Patient.make(agep_id: '123456789').should be_valid
    end

    it "should validate 10 digits IDs" do
      Patient.make(agep_id: '1234567890').should be_valid
    end

    it "should reject non-digit IDs" do
      Patient.make(agep_id: 'ABCDEFG').should_not be_valid
    end

    it "should reject IDs of length other than 7, 9 or 10" do
      (0..15).each do |length|
        unless length == 7 || length == 9 || length == 10
          Patient.make(agep_id: '1'*length).should_not be_valid
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

  describe "unassign card" do
    before(:each) do
      @card = Card.make!(:with_vouchers, created_at: 1.day.ago)
      @patient = Patient.make!
      @patient.current_card = @card
      @patient.save!
    end

    it "should set patient's current card to nil" do
      @patient.unassign_card!
      @patient.current_card.should be_nil
    end

    it "should unlink the card from the patient" do
      @patient.unassign_card!
      @card.patient.should be_nil
    end

    it "should reset card validity" do
      @card.update_attribute :validity, Date.today

      @patient.unassign_card!
      @patient.current_card.should be_nil
      @card.validity.should be_nil
    end

    it "should not unassign if the card has any voucher used" do
      @card.vouchers.first.update_attribute :used, true

      @patient.unassign_card!
      @patient.current_card.should eq(@card)
      @card.patient.should eq(@patient)
    end

    it "should unassign if the card is not active" do
      @card.vouchers.first.update_attribute :used, true
      @card.update_attribute :validity, Date.today
      @card.deactivate!

      @patient.unassign_card!
      @patient.current_card.should be_nil
      @card.patient.should be_nil
      @card.validity.should_not be_nil
    end
  end

  describe "deactivate card" do
    before(:each) do
      @card = Card.make!
      @patient = Patient.make!
      @patient.current_card = @card
      @patient.save!
    end

    it "should set the patient's current card to nil" do
      @patient.deactivate_card!
      @patient.current_card.should be_nil
    end

    it "should not unlink the card from the patient" do
      @patient.deactivate_card!
      @card.patient.should eq(@patient)
    end

    it "should change the card's status to inactive" do
      @patient.deactivate_card!
      @card.should be_inactive
    end

    it "should change the card's status to lost if reported as such" do
      @patient.deactivate_card! :lost
      @card.should be_lost
    end
  end
end
