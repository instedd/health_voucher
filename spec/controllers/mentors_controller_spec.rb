require 'rails_helper'

describe MentorsController do
  before(:each) do
    @site = Site.make!
    @mentor = Mentor.make! site: @site
  end

  context "with admin" do
    before(:each) do
      @user = User.make!(:admin)
      sign_in @user
    end

    it "POST create" do
      expect do
        post :create, site_id: @site.id, mentor: {name: 'Joe Mentor'}
      end.to change(Mentor, :count).by(1)

      new_mentor = Mentor.last
      expect(new_mentor.name).to eq('Joe Mentor')
      expect(new_mentor.site).to eq(@site)
    end
  end

  describe "access" do
    context "for site managers" do
      before(:each) do
        @user = User.make!(:site_manager)
        sign_in @user
      end

      context "of another site" do
        before(:each) do
          @other_site = Site.make! user: @user
        end

        { :get => %w(index show),
          :post => %w(create add_patients auto_assign move_patients batch_validate),
          :delete => %w(destroy) }.each do |method, actions|
          actions.each do |action|
            describe "#{method} #{action}" do
              it "should be denied" do
                send(method, action, site_id: @site.id, id: @mentor.id)
                response.status.should == 401
              end
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
        get :show, site_id: @site.id, id: @mentor.id
        response.status.should == 200
      end

      { :post => %w(create add_patients auto_assign move_patients batch_validate),
        :delete => %w(destroy) }.each do |method, actions|
        actions.each do |action|
          describe "#{method} #{action}" do
            it "should be denied" do
              send(method, action, site_id: @site.id, id: @mentor.id)
              response.status.should == 401
            end
          end
        end
      end
    end
  end
end
