require 'spec_helper'

describe Statement::Generator do
  before(:each) do
  end

  describe "find transactions" do
    it "should find transactions for providers of the clinic"
    it "should not find transactions from training cards"
    it "should not find transactions if the clinic is for training"
    it "should find transactions with no previous statement"
    it "should find only unpaid transactions"
    it "should only find transactions made before until date"
  end

  describe "generate" do
    it "should not generate a statement if the clinic is for training"
    it "should not generate a statement if there are no transactions to include"
    it "should set the statement in each of the included transactions"
    it "should calculate a total amount for the statement"
  end
end
