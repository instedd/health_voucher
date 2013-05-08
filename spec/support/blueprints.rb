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

Site.blueprint do
  name { "Site" }
end

Clinic.blueprint do
  site { Site.make! }
  name { "Clinic" }
end

Provider.blueprint do
  clinic { Clinic.make! }
  code { _provider_code }
  name { "Provider #{code}" }
  enabled { true }
end

Service.blueprint do
  description { "Some service" }
  short_description { "Service" }
  service_type { :primary }
  code { _service_code }
end

Authorization.blueprint do
  card { Card.make! }
  provider { Provider.make! }
  service { Service.make! }
end

Transaction.blueprint do 
  provider { Provider.make! }
  voucher { Voucher.make! }
  service { Service.make! }
  authorization { Authorization.make! }
  status { :pending }
end

Patient.blueprint do
  agep_id { sn.to_s.rjust(10, '0') }
end

def _serial_number
  Card::Code.generate(Card::SERIAL_NUMBER_LENGTH)
end

def _pin_code
  Card::Code.generate_with_check(Voucher::VOUCHER_CODE_LENGTH)
end

def _provider_code
  begin
    code = rand(1..999).to_s.rjust(3, '0')
  end while Provider.find_by_code(code)
  code
end

def _service_code
  begin
    code = rand(10..99).to_s.rjust(2, '0')
  end while Service.find_by_code(code)
  code
end

