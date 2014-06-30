require 'spec_helper'

describe TransactionsController do
  before(:each) do
    @txn = Transaction.make!
  end

  describe "access" do
    describe "for auditor" do
      before(:each) do
        @user = User.make!(:auditor)
        sign_in @user
      end

      it "GET index should be allowed" do
        get :index
        response.status.should == 200
      end

      it "POST update_status should be denied" do
        post :update_status, id: @txn.id
        response.status.should == 401
      end
    end

    describe "for site manager" do
      before(:each) do
        @user = User.make!(:site_manager)
        sign_in @user
      end

      it "GET index should be denied" do
        get :index
        response.status.should == 401
      end

      it "POST update_status should be denied" do
        post :update_status, id: @txn.id
        response.status.should == 401
      end
    end
  end
end
