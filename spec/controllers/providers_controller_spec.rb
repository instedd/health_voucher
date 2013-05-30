require 'spec_helper'

describe ProvidersController do
  before(:each) do
    @provider = Provider.make!
  end

  describe "security" do
    before(:each) do
      @user = User.make!
    end

    { :post => %w(create toggle),
      :delete => %w(destroy) }.each do |method, actions|
      actions.each do |action|
        describe "#{method} #{action}" do
          it "should deny a non-admin user" do
            sign_in @user
            send(method, action, id: @provider.id)
            response.status.should == 401
          end
        end
      end
    end
  end
end
