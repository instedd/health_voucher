require 'spec_helper'

describe PatientsController do
  before(:each) do
    @admin = User.make!(:admin)
    @manager = User.make!
    @user = User.make!

    @site = Site.make! user: @manager
    @mentor = Mentor.make! site: @site
    @patient = Patient.make! mentor: @mentor
  end

  describe "load patient" do
    before(:each) do
      controller.params[:id] = @patient.id
    end

    it "should allow an admin" do
      sign_in @admin

      controller.expects(:permission_denied).never
      controller.send(:load_patient)
    end

    it "should allow the patient's site manager" do
      sign_in @manager

      controller.expects(:permission_denied).never
      controller.send(:load_patient)
    end

    it "should deny any other non-admin user" do
      sign_in @user

      controller.expects(:permission_denied)
      controller.send(:load_patient)
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
