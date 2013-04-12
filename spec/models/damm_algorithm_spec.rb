require 'spec_helper'

describe DammAlgorithm do
  pending "add some examples to (or delete) #{__FILE__}"

  it "should it generate damm crc digit" do
    DammAlgorithm.calculate_crc_digit( 99 ).should eq 5
    DammAlgorithm.calculate_crc_digit( 99 ).should eq 2
    DammAlgorithm.calculate_crc_digit( 99 ).should eq 1
  end

  pending "should it change one digit of damm crc signed code"

end
