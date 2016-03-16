require 'spec_helper'

describe SitesController do
  before(:each) do
    @site = Site.make!
  end

  context "with admin user" do
    before(:each) do
      @user = User.make!(:admin)
      sign_in @user
    end

    it "POST create" do
      expect do
        post :create, site: {name: 'New Site', training: '1'}
      end.to change(Site, :count).by(1)

      created_site = Site.last
      expect(created_site.name).to eq('New Site')
      expect(created_site.training).to be_truthy
    end

    it "PATCH update" do
      patch :update, id: @site.id, site: {name: 'Changed Site', training: '1'}

      expect(@site.reload.name).to eq('Changed Site')
      expect(@site.reload.training).to be_truthy
    end

    it "PUT update_manager" do
      expect do
        put :update_manager, id: @site.id, user: {email: 'user@example.com',
                                                  password: 'secret',
                                                  password_confirmation: 'secret'}
      end.to change(User, :count).by(1)
      new_manager = User.last
      expect(new_manager.email).to eq('user@example.com')
      expect(new_manager).to be_site_manager
    end
  end

  describe "access" do
    context "for site managers" do
      before(:each) do
        @user = User.make!
        sign_in @user
      end

      it "POST create should be denied" do
        post :create, site: {name: 'Site'}
        expect(response.status).to be(401)
      end

      { :get => %w(index show new edit assign_cards edit_manager),
        :put => %w(update update_manager),
        :post => %w(batch_assign_cards assign_individual_card return_cards set_manager),
        :delete => %w(destroy_manager) }.each do |method, actions|
        actions.each do |action|
          describe "#{method.upcase} #{action}" do
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

      it "POST create should be denied" do
        post :create, site: {name: 'Site'}
        expect(response.status).to be(401)
      end

      { :get => %w(new edit assign_cards edit_manager),
        :put => %w(update update_manager),
        :post => %w(batch_assign_cards assign_individual_card return_cards set_manager),
        :delete => %w(destroy_manager) }.each do |method, actions|
        actions.each do |action|
          describe "#{method.upcase} #{action}" do
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

