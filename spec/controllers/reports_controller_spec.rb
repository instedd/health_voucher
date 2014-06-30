require 'spec_helper'

describe ReportsController do
  describe "access" do
    context "for site manager" do
      before(:each) do
        @user = User.make!
        sign_in @user
      end

      %i(card_allocation transactions services clinics).each do |action|
        it "GET #{action} should be denied" do
          get action
          response.status.should == 401
        end
      end
    end
  end
end
