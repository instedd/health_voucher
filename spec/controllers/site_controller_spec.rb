require 'spec_helper'

describe SiteController do
  describe "load site" do
    [:admin, :auditor].each do |role|
      before(:each) do
        @user = User.make!(role)
        sign_in @user
      end

      context "as #{role}" do
        context "with sites" do
          before(:each) do
            @site = Site.make!
          end

          it "should load the site if parameter present" do
            controller.params[:site_id] = @site.id
            controller.send(:load_site)
            assigns(:site).should eq(@site)
          end

          it "should load the first site available if parameter is blank" do
            controller.send(:load_site)
            assigns(:site).should eq(@site)
          end
        end

        context "without sites" do
          it "should redirect to sites if parameter when parameter is blank" do
            controller.expects(:redirect_to).with(sites_path)
            controller.send(:load_site)
          end
        end
      end
    end

    context "as site manager" do
      before(:each) do
        @user = User.make!
        sign_in @user
      end

      context "without sites" do
        it "should respond with permission denied" do
          controller.expects(:permission_denied)
          controller.send(:load_site)
        end
      end

      context "with sites" do
        before(:each) do
          @user_site = Site.make! user: @user
          @other_site = Site.make!
        end

        it "should load the user's site" do
          controller.params[:site_id] = @user_site.id
          controller.send(:load_site)
          assigns(:site).should eq(@user_site)
        end

        it "should load the user's site if parameter is blank" do
          controller.send(:load_site)
          assigns(:site).should eq(@user_site)
        end

        it "should respond with permission denied if trying to load another site" do
          controller.params[:site_id] = @other_site.id
          controller.expects(:permission_denied)
          controller.send(:load_site)
        end
      end
    end
  end
end
