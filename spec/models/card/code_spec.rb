require "spec_helper"

describe "Card::Code" do
  before(:each) do
    @code = Card::Code
  end

  describe "generate" do
    it "should generate a string of the given length" do
      @code.generate(15).length.should eq(15)
    end

    it "should generate a string of digits" do
      @code.generate(20).should match(/\A[0-9]+\Z/)
    end
  end

  describe "generate with check" do
    it "should generate a string of the given length" do
      @code.generate_with_check(12).length.should eq(12)
    end

    it "should generate a valid check digit" do
      code = @code.generate_with_check(12)
      Card::Damm.generate(code).should eq('0')
    end
  end

  describe "check" do
    it "should validate codes with valid check digit" do
      code = @code.generate_with_check(12)
      @code.check(code).should be_true
    end

    it "should not validate codes with invalid check digit" do
      @code.check('5721').should be_false   # 572 -> 4
    end
  end

  describe "generate voucher code" do
    it "should generate a 12 digit code" do
      @code.generate_voucher_code.size.should eq(12)
      @code.generate_voucher_code.should match /\A[0-9]{12}\z/
    end

    it "should generate a valid code" do
      100.times do
        @code.check(@code.generate_voucher_code).should be_true
      end
    end

    it "first digit should never be zero" do
      100000.times.each do 
        @code.generate_voucher_code.start_with?('0').should be_false
      end
    end
  end
end
