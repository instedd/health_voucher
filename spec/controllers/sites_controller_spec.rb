require 'spec_helper'

describe SitesController do
  before(:each) do
    @site = Site.make!
  end

  describe "security" do
    before(:each) do
      @user = User.make!
    end

    { :get => %w(index show new edit assign_cards edit_manager),
      :put => %w(update update_manager),
      :post => %w(create batch_assign_cards assign_individual_card return_cards set_manager),
      :delete => %w(destroy_manager) }.each do |method, actions|
      actions.each do |action|
        describe "#{method} #{action}" do
          it "should deny a non-admin user" do
            sign_in @user
            send(method, action, id: @site.id)
            response.status.should == 401
          end
        end
      end
    end
  end
end
