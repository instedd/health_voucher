require 'spec_helper'

describe Voucher do
  before(:each) do
    @voucher = Voucher.make
  end

  describe "code validations" do
    it "should validate a valid code" do
      @voucher.code = Card::Code.generate_voucher_code
      @voucher.should be_valid
    end

    it "should reject short codes" do
      @voucher.code = '1234567890'
      @voucher.should_not be_valid
    end

    it "should reject non-digit codes" do
      @voucher.code = 'aaabbbcccddd'
      @voucher.should_not be_valid
    end
  end
end
