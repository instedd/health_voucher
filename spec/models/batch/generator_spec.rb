require 'spec_helper'

describe Batch::Generator do
  before(:each) do
    @batch = Batch.make! initial_serial_number: 100, quantity: 10
    @generator = Batch::Generator.new(@batch)
  end

  it "should generate quantity cards" do
    lambda do
      @generator.generate!
    end.should change(Card, :count).by(@batch.quantity)
    @batch.reload.cards.count.should eq(@batch.quantity)
  end

  it "should generate sequential serial numbers" do
    @generator.generate!
    from = @batch.initial_serial_number.to_i
    to = from + @batch.quantity - 1
    (from..to).each do |sn|
      Card.find_by_serial_number(sn).should_not be_nil
    end
  end

  it "should run twice without errors" do
    lambda do
      @generator.generate!
      @generator.generate!
    end.should_not raise_error
  end

  it "should generate complete cards" do
    @generator.generate!
    @batch.reload.cards.each do |card|
      card.vouchers.select { |v| v.primary? }.count.should eq(Card::PRIMARY_SERVICES)
      card.vouchers.select { |v| v.secondary? }.count.should eq(Card::SECONDARY_SERVICES)
    end
  end

  it "should generate valid cards" do
    @generator.generate!
    @batch.reload.cards.each do |card|
      card.check_digit.should eq(Card::Damm.generate(card.serial_number))
      card.vouchers.each do |voucher|
        Card::Code.check(voucher.code).should be_true
      end
    end
  end

  it "should retry voucher code generation when there are code collisions" do
    last_code = nil
    # fix the voucher code generation to always return a code twice
    Card::Code.should_receive(:generate_voucher_code) do
      if last_code.nil?
        last_code = Card::Code.generate_with_check(Voucher::VOUCHER_CODE_LENGTH, first_non_zero: true)
      else
        code = last_code
        last_code = nil
        code
      end
    end.at_least(2 * @batch.quantity * (Card::PRIMARY_SERVICES + Card::SECONDARY_SERVICES) - 1)

    @generator.generate!
    @batch.reload.cards.each do |card|
      card.vouchers.select { |v| v.primary? }.count.should eq(Card::PRIMARY_SERVICES)
      card.vouchers.select { |v| v.secondary? }.count.should eq(Card::SECONDARY_SERVICES)
    end
  end
end

