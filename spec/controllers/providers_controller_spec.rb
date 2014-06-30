require 'spec_helper'

describe ProvidersController do
  before(:each) do
    @provider = Provider.make!
  end

  describe "access" do
    [:site_manager, :auditor].each do |role|
      context "for #{role}" do
        before(:each) do
          @user = User.make!(role)
        end

        { :post => %w(create toggle),
          :delete => %w(destroy) }.each do |method, actions|
          actions.each do |action|
            describe "#{method} #{action}" do
              it "should be denied" do
                sign_in @user
                send(method, action, id: @provider.id)
                response.status.should == 401
              end
            end
          end
        end
      end
    end
  end
end
