require 'spec_helper'

describe Transaction do
  describe "update status" do
    before(:each) do
      @txn = Transaction.make!
    end

    it "should update status and comments" do
      @txn.update_status(:pending, '123').should be_true
      @txn.should be_valid
      @txn.should be_pending
      @txn.comment.should eq('123')
    end

    it "should not allow updates if the transaction is from training" do
      site = @txn.provider.site
      site.update_attribute :training, true

      @txn.authorization.should be_training
      @txn.should be_training

      @txn.update_status(:pending, '123').should be_false
      @txn.should be_unpaid
      @txn.comment.should be_nil
    end

    it "should not allow updates if the transaction is already included in a statement" do
      @stmt = Statement.make! clinic: @txn.clinic
      @txn.update_attribute :statement, @stmt

      @txn.update_status(:pending, '123').should be_false
      @txn.should be_unpaid
      @txn.comment.should be_nil
    end
  end
end
