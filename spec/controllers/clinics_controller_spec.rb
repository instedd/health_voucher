require 'spec_helper'

describe ClinicsController do
  before(:each) do
    @site = Site.make!
    @clinic = Clinic.make! site: @site
  end

  context "with admin" do
    before(:each) do
      @user = User.make!(:admin)
      sign_in @user
    end

    it "POST create" do
      expect do
        post :create, format: 'js', site_id: @site.id, clinic: {name: 'Clinic Name'}
      end.to change(Clinic, :count).by(1)

      new_clinic = Clinic.last
      expect(new_clinic.name).to eq('Clinic Name')
      expect(new_clinic.site).to eq(@site)
    end
  end

  describe "access" do
    context "for site managers" do
      before(:each) do
        @user = User.make!
        sign_in @user
      end

      it "POST create should be denied" do
        post :create, site_id: @site.id, clinic: {name: 'My Clinic'}
        expect(response.status).to be(401)
      end

      { :get => %w(index show services),
        :post => %w(toggle_service set_service_cost),
        :delete => %w(destroy) }.each do |method, actions|
        actions.each do |action|
          describe "#{method} #{action}" do
            it "should be denied" do
              send(method, action, site_id: @site.id, id: @clinic.id)
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
        get :index, site_id: @site.id
        response.status.should == 200
      end

      it "GET show should be allowed" do
        get :show, site_id: @site.id, id: @clinic.id
        response.status.should == 200
      end

      it "GET services should be allowed" do
        get :services, site_id: @site.id, id: @clinic.id
        response.status.should == 200
      end

      it "POST create should be denied" do
        post :create, site_id: @site.id, clinic: {name: 'My Clinic'}
        expect(response.status).to be(401)
      end

      { :post => %w(toggle_service set_service_cost),
        :delete => %w(destroy) }.each do |method, actions|
        actions.each do |action|
          describe "#{method} #{action}" do
            it "should be denied" do
              send(method, action, site_id: @site.id, id: @clinic.id)
              response.status.should == 401
            end
          end
        end
      end
    end
  end
end
