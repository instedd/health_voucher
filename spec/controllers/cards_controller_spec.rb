require 'spec_helper'

describe CardsController do
  before(:each) do
    @admin = User.make!(:admin)
    @user = User.make!
    @auditor = User.make!(:auditor)
  end

  describe "start_validity" do
    before(:each) do
      @patient = Patient.make!
      @card = Card.make! patient: @patient
      @site = @patient.site
    end

    it "should allow an admin" do
      sign_in @admin

      post :start_validity, id: @card.id, validity: Date.today

      response.should be_redirect
    end

    it "should deny an auditor" do
      sign_in @auditor

      post :start_validity, id: @card.id, validity: Date.today

      response.should_not be_redirect
    end

    it "should allow a site manager if the card's patient belongs to his site" do
      @site.update_attribute :user_id, @user.id

      sign_in @user

      post :start_validity, id: @card.id, validity: Date.today

      response.should be_redirect
    end

    it "should deny a site manager if the card's patient is from another site" do
      @another_site = Site.make! user: @user

      sign_in @user

      post :start_validity, id: @card.id, validity: Date.today
      
      response.should_not be_redirect
    end
  end
end
