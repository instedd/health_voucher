require 'spec_helper'

describe TransactionsController do
  before(:each) do
    @txn = Transaction.make!
  end

  describe "security" do
    before(:each) do
      @user = User.make!
    end

    { :get => %w(index),
      :post => %w(update_status) }.each do |method, actions|
      actions.each do |action|
        describe "#{method} #{action}" do
          it "should deny a non-admin user" do
            sign_in @user
            send(method, action, id: @txn.id)
            response.status.should == 401
          end
        end
      end
    end
  end
end
