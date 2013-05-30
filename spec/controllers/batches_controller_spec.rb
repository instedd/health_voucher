require 'spec_helper'

describe BatchesController do
  before(:each) do
    @batch = Batch.make!
  end

  describe "security" do
    before(:each) do
      @user = User.make!
    end

    { :get => %w(index show new),
      :post => %w(create) }.each do |method, actions|
      actions.each do |action|
        describe "#{method} #{action}" do
          it "should deny a non-admin user" do
            sign_in @user
            send(method, action, id: @batch.id)
            response.status.should == 401
          end
        end
      end
    end
  end
end
