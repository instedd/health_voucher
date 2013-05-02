class Fixnum
  def to_serial_number
    self.to_s.rjust(Card::SERIAL_NUMBER_LENGTH, '0')
  end
end

