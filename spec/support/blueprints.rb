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

Card.blueprint(:with_vouchers) do
  vouchers { 6.times.map { Voucher.make } + 7.times.map { Voucher.make(:secondary) } }
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
  training { false }
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

Service.blueprint(:secondary) do
  service_type { :secondary }
end

ClinicService.blueprint do
  clinic { Clinic.make! }
  service { Service.make! }
  enabled { true }
  cost { 1.0 }
end

Authorization.blueprint do
  card { Card.make! }
  provider { Provider.make! }
  service { Service.make! }
end

Transaction.blueprint do 
  voucher { Voucher.make! }
  authorization { Authorization.make! }
  status { :pending }
end

Mentor.blueprint do
  name { "Mentor #{sn}" }
  site { Site.make! }
end

Patient.blueprint do
  agep_id { sn.to_s.rjust(10, '0') }
  mentor { Mentor.make! }
end

Patient.blueprint(:agep_id_7) do
  agep_id { sn.to_s.rjust(7, '0') }
end

def _serial_number
  last_card = Card.order('serial_number DESC').first
  if last_card
    (last_card.serial_number.to_i + 1).to_serial_number
  else
    1.to_serial_number
  end
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

