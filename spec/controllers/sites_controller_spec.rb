require 'spec_helper'

describe SitesController do
  before(:each) do
    @site = Site.make!
  end

  describe "access" do
    context "for site managers" do
      before(:each) do
        @user = User.make!
        sign_in @user
      end

      { :get => %w(index show new edit assign_cards edit_manager),
        :put => %w(update update_manager),
        :post => %w(create batch_assign_cards assign_individual_card return_cards set_manager),
        :delete => %w(destroy_manager) }.each do |method, actions|
        actions.each do |action|
          describe "#{method} #{action}" do
            it "should be denied" do
              send(method, action, id: @site.id)
              response.status.should == 401
            end
          end
        end
      end
    end

    context "for auditors" do
      before(:each) do
        @user = User.make!(:auditor)
        sign_in @user
      end

      it "GET index should be allowed" do
        get :index
        response.status.should == 200
      end

      it "GET show should be allowed" do
        get :show, id: @site.id
        response.status.should == 200
      end

      { :get => %w(new edit assign_cards edit_manager),
        :put => %w(update update_manager),
        :post => %w(create batch_assign_cards assign_individual_card return_cards set_manager),
        :delete => %w(destroy_manager) }.each do |method, actions|
        actions.each do |action|
          describe "#{method} #{action}" do
            it "should be denied" do
              send(method, action, id: @site.id)
              response.status.should == 401
            end
          end
        end
      end
    end
  end
end

