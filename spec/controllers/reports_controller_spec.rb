require 'rails_helper'

describe ReportsController do
  describe "smoke tests" do
    before(:each) do
      @user = User.make!(:admin)
      sign_in @user
    end

    it "GET card_allocation" do
      get :card_allocation
      expect(response.status).to be(200)
    end

    it "GET card_allocation by mentor" do
      get :card_allocation, by: 'mentor'
      expect(response.status).to be(200)
    end

    it "GET transactions" do
      get :transactions
      expect(response.status).to be(200)
    end

    it "GET transactions by clinic" do
      get :transactions, by: 'clinic'
      expect(response.status).to be(200)
    end

    it "GET services" do
      get :services
      expect(response.status).to be(200)
    end

    it "GET services by clinic" do
      get :services, by: 'clinic'
      expect(response.status).to be(200)
    end

    it "GET clinics" do
      get :clinics
      expect(response.status).to be(200)
    end
  end

  describe "access" do
    context "for site manager" do
      before(:each) do
        @user = User.make!
        sign_in @user
      end

      %w(card_allocation transactions services clinics).each do |action|
        it "GET #{action} should be denied" do
          get action.to_sym
          response.status.should == 401
        end
      end
    end
  end
end
