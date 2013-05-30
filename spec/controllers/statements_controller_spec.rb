require 'spec_helper'

describe StatementsController do
  before(:each) do
    @stmt = Statement.make!
  end

  describe "security" do
    before(:each) do
      @user = User.make!
    end

    { :get => %w(index show generate),
      :post => %w(toggle_status do_generate),
      :delete => %w(destroy) }.each do |method, actions|
      actions.each do |action|
        describe "#{method} #{action}" do
          it "should deny a non-admin user" do
            sign_in @user
            send(method, action, id: @stmt.id)
            response.status.should == 401
          end
        end
      end
    end
  end
end

