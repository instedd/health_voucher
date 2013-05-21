require 'spec_helper'

describe Statement do
  describe "destroy" do
    before(:each) do
      @stmt = Statement.make!
      @txn1 = Transaction.make! statement: @stmt, status: :paid
    end

    it "should nullify its transactions" do
      @stmt.destroy

      @txn1.reload.statement_id.should be_nil
    end

    it "should mark its transactions as unpaid before nullifying" do
      @stmt.destroy

      @txn1.reload.should be_unpaid
    end
  end
end

