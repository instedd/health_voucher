require 'machinist/active_record'

Batch.blueprint do
  name { "Batch #{sn}" }
  initial_serial_number { _serial_number }
  quantity { 1 }
end

Card.blueprint do
  batch { Batch.make! }
  serial_number { _serial_number }
end

Voucher.blueprint do
  card { Card.make! }
  code { _pin_code }
  service_type { :primary }
end

Voucher.blueprint(:secondary) do
  service_type { :secondary }
end

def _serial_number
  Card::Code.generate(Card::SERIAL_NUMBER_LENGTH)
end

def _pin_code
  Card::Code.generate_with_check(Voucher::VOUCHER_CODE_LENGTH)
end

