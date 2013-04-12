module CodeGenerator

  def self.generate_digits(digits)
    code = rand(10**(digits-2)...10**(digits-1))

    return "#{code}#{DammAlgorithm.calculate_crc_digit(code)}"
  end

end
