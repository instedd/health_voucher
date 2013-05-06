module Card::Code
  def self.generate(digits, options = {})
    if options.delete(:first_non_zero)
      (rand(9) + 1).to_s + self.generate(digits - 1, options)
    else
      digits.times.map { rand(10).to_s }.join
    end
  end

  def self.generate_with_check(digits, options = {})
    code = self.generate(digits - 1, options)
    code << Card::Damm.generate(code)
  end

  def self.check(code)
    Card::Damm.generate(code) == '0'
  end

  def self.generate_voucher_code
    self.generate_with_check(Voucher::VOUCHER_CODE_LENGTH, first_non_zero: true)
  end
end

