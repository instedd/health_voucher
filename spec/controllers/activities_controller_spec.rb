require 'rails_helper'

describe ActivitiesController do
  describe "access" do
    [:site_manager, :auditor].each do |role|
      context "for #{role}" do
        before(:each) do
          @user = User.make!(role)
          @other = User.make!
          sign_in @user
        end

        it "GET index should be denied" do
          get :index
          response.status.should == 401
        end
      end
    end
  end
end
