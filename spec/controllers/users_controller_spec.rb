require 'spec_helper'

describe UsersController do
  describe "security" do
    before(:each) do
      @user = User.make!
      @other = User.make!
    end

    { :get => %w(index new edit),
      :put => %w(update),
      :post => %w(create),
      :delete => %w(destroy) }.each do |method, actions|
      actions.each do |action|
        describe "#{method} #{action}" do
          it "should deny a non-admin user" do
            sign_in @user
            send(method, action, id: @other.id)
            response.status.should == 401
          end
        end
      end
    end
  end
end
