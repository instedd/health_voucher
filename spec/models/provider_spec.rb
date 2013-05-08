require 'spec_helper'

describe Provider do
  describe "destroy" do
    it "should not be destroyed if he has registered transactions" do
      @provider = Provider.make!
      @txn = Transaction.make! provider: @provider

      @provider.destroy
      @provider.should_not be_destroyed
    end
  end
end
