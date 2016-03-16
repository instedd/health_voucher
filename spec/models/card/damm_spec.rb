require "rails_helper"

describe "Card::Damm" do
  before(:each) do
    @damm = Card::Damm
  end

  it "should generate a valid check digit" do
    @damm.generate('572').should eq('4')    
    @damm.generate('123456789').should eq('4')    
  end

  it "should not care about leading zeros" do
    code = '2309487'
    1.upto(5).each do |zeros|
      @damm.generate(code).should eq(@damm.generate('0'*zeros + code))
    end
  end

  it "should detect single digit mistakes" do
    code = '2304987234'
    (0..code.length-1).each do |index|
      digit = code[index]
      new_digit = (digit.to_i + rand(9) + 1) % 10
      new_code = code.dup
      new_code[index] = new_digit.to_s
      @damm.generate(code).should_not eq(@damm.generate(new_code))
    end
  end

  it "should detect two digit transpositions" do
    code = '450979138459'
    (0..code.length-2).each do |index|
      new_code = code.dup
      new_code[index] = code[index + 1]
      new_code[index + 1] = code[index]
      @damm.generate(code).should_not eq(@damm.generate(new_code))
    end
  end
end

