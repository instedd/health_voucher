require 'machinist/active_record'

User.blueprint do
  email { "user#{sn}@example.com" }
  password { rand(10**6..10**8).to_s }
end

User.blueprint(:admin) do
  role { :admin }
end

User.blueprint(:auditor) do
  role { :auditor }
end

User.blueprint(:site_manager) do
end

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
  vouchers { Card::PRIMARY_SERVICES.times.map { Voucher.make(:primary) } + 
             Card::SECONDARY_SERVICES.times.map { Voucher.make(:secondary) } }
end

Card.blueprint(:with_any_vouchers) do
  vouchers { Card::ANY_SERVICES.times.map { Voucher.make } }
end

Voucher.blueprint do
  card { Card.make! }
  code { _pin_code }
  service_type { :any }
end

Voucher.blueprint(:primary) do
  service_type { :primary }
end

Voucher.blueprint(:secondary) do
  service_type { :secondary }
end

Site.blueprint do
  name { "Site" }
  training { false }
end

Site.blueprint(:training) do
  training { true }
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
  status { :unpaid }
  amount { 1.0 }
end

Statement.blueprint do
  clinic { Clinic.make! }
  status { :unpaid }
  self.until { Date.today }
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
    code = rand(1..9999).to_s.rjust(4, '0')
  end while Provider.find_by_code(code)
  code
end

def _service_code
  begin
    code = rand(10..99).to_s.rjust(2, '0')
  end while Service.find_by_code(code)
  code
end

