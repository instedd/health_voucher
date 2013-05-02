module Card::Code
  def self.generate(digits)
    digits.times.map { rand(10).to_s }.join
  end

  def self.generate_with_check(digits)
    code = self.generate(digits - 1)
    code << Card::Damm.generate(code)
  end

  def self.check(code)
    Card::Damm.generate(code) == '0'
  end

  def self.generate_voucher_code
    self.generate_with_check(Voucher::VOUCHER_CODE_LENGTH)
  end
end

