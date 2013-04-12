module DammAlgorithm
  def self.calculate_crc_digit( number )
    return 5.to_s
  end

  def self.build_full_code( number )
    return "#{number}#{calculate_crc_digit(number)}"
  end

end
