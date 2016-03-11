require 'spec_helper'

describe PatientsController do
  before(:each) do
    @admin = User.make!(:admin)
    @manager = User.make!
    @user = User.make!
    @auditor = User.make!(:auditor)

    @site = Site.make! user: @manager
    @mentor = Mentor.make! site: @site
    @patient = Patient.make! mentor: @mentor
  end

  describe "load patient" do
    before(:each) do
      controller.params[:id] = @patient.id
      controller.params[:action] = 'manage'
    end

    it "should allow an admin" do
      sign_in @admin

      lambda do
        controller.send(:load_patient)
      end.should_not raise_error
    end

    it "should allow the patient's site manager" do
      sign_in @manager

      lambda do
        controller.send(:load_patient)
      end.should_not raise_error
    end

    it "should deny an auditor" do
      sign_in @auditor

      lambda do
        controller.send(:load_patient)
      end.should raise_error(Pundit::NotAuthorizedError)
    end

    it "should deny any other site manager" do
      sign_in @user

      lambda do
        controller.send(:load_patient)
      end.should raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "assign card" do
    before(:each) do
      @card = Card.make! site: @site
      @another_card = Card.make!

      sign_in @manager
    end

    it "should assign if the card belongs to the site" do
      post :assign_card, :id => @patient.id, :serial_number => @card.serial_number
      response.should be_redirect
      @patient.reload.current_card.should eq(@card)
    end

    it "should not assign cards from other sites" do
      post :assign_card, :id => @patient.id, :serial_number => @another_card.serial_number
      response.should be_redirect
      @patient.reload.current_card.should be_nil
    end
  end
end
