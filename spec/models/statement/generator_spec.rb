require 'spec_helper'

describe Statement::Generator do
  def make_transaction(options = {})
    auth = Authorization.make! options
    Transaction.make! authorization: auth
  end

  before(:each) do
    @until = Date.new(2013,5,1)

    @clinic = Clinic.make!
    @provider = Provider.make! clinic: @clinic
    @generator = Statement::Generator.new(@clinic, @until)

    Timecop.travel(@until.yesterday)
    @txn1 = make_transaction provider: @provider
    @txn2 = make_transaction provider: @provider
  end

  describe "find transactions" do
    it "should find transactions for providers of the clinic" do
      @generator.find_transactions.should include(@txn1)
      @generator.find_transactions.should include(@txn2)
    end

    it "should not find transactions from training cards" do
      @training_site = Site.make!(:training) 
      @training_card = Card.make!(:with_vouchers, site: @training_site)
      
      @training_txn = make_transaction card: @training_card, provider: @provider

      @generator.find_transactions.should_not include(@training_txn)
    end

    it "should not find transactions if the clinic is for training" do
      @clinic.site.update_attribute :training, true

      @generator.find_transactions.should be_empty
    end

    it "should find transactions with no previous statement" do
      @other_stmt = Statement.make!
      @txn1.update_attribute :statement_id, @other_stmt.id

      @generator.find_transactions.should_not include(@txn1)
    end

    it "should find only unpaid transactions" do
      @txn1.update_status :rejected, 'foo'

      @generator.find_transactions.should_not include(@txn1)
    end

    it "should only find transactions made before until date" do
      Timecop.travel(@until.tomorrow)

      @txn3 = make_transaction provider: @provider

      @generator.find_transactions.should_not include(@txn3)
    end
  end

  describe "generate" do
    it "should not generate a statement if the clinic is for training" do
      @clinic.site.update_attribute :training, true

      lambda do
        @generator.generate
      end.should_not change(Statement, :count)
    end

    it "should not generate a statement if there are no transactions to include" do
      @txn1.update_status :pending, '123'
      @txn2.update_status :pending, '123'

      @generator.find_transactions.should be_empty

      lambda do
        @generator.generate
      end.should_not change(Statement, :count)
    end

    it "should set the statement in each of the included transactions" do
      stmt = @generator.generate

      @txn1.reload.statement.should eq(stmt)
      @txn2.reload.statement.should eq(stmt)
    end

    it "should calculate a total amount for the statement" do
      @clinic.clinic_service_for(@txn1.service).tap do |cs|
        cs.cost = 1
        cs.save!
      end
      @clinic.clinic_service_for(@txn2.service).tap do |cs|
        cs.cost = 10
        cs.save!
      end

      stmt = @generator.generate
      stmt.total.should eq(11)
    end
  end
end