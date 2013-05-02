class String
  def to_serial_number
    self.rjust(Card::SERIAL_NUMBER_LENGTH, '0')
  end
end
