# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

SERVICES = [
  ["11", "Wellness Check", "Wellness Check", "primary"] ,
  ["12", "Wellness Check Plus", "Wellness Check+", "primary"],
  ["21", "FP consultation without provision of method, this can include removal of implant or IUD", "FP Consult", "primary"],
  ["22", "Just provision of pills", "FP-Pills", "secondary"],
  ["23", "FP consultation plus provision of pills (evt. condoms)", "FP Consult + Pills", "primary"],
  ["24", "Just injection with FP injectable", "FP-Injection", "secondary"],
  ["25", "FP consultation plus PF injectable (evt condoms)", "FP Consult + Injection", "primary"],
  ["26", "FP consultation plus insertion of implant", "FP Consult + Implant", "primary"],
  ["27", "FP consultation plus insertion of IUD", "FP Consult + IUD", "primary"],
  ["28", "FP consultation plus Emergency Contraception", "FP Consult + EC", "primary"],
  ["31", "Pregnancy Test plus refereal", "Preg Test", "primary"],
  ["41", "RTI/STI consultation or follow-up consult for girls or partner", "STI Consult", "primary"],
  ["42", "Treatment of discharge (includes consultation)", "STI Consult+Treat", "primary"],
  ["43", "Girl + partner treated for discharge (incl consultation)", "STI Partner ConsTreat", "primary"],
  ["44", "RPR test", "RPR Test", "secondary"],
  ["45", "Treatment of genital ulcers, bubo, etc. (incl consultation)", "Gen Ulcer Treat", "primary"],
  ["51", "HIV counseling, testing and referal", "HIV Test", "primary"],
  ["61", "ANC1 (includes laboratory tests)", "ANC Visit 1", "primary"],
  ["71", "CAC – Medical Safe abortion (TOP) - mifepristone and misoprostol (MA)", "CAC Medical", "primary"],
  ["72", "CAC – Surgical Safe abortion (TOP) - vacuum aspiration (MVA)/surgical", "CAC Surgical", "primary"],
  ["73", "PAC – Medical Incomplete abortion (PAC) - misoprostol (MPAC)", "PAC Medical", "primary"],
  ["74", "PAC – Surgical Incomplete abortion (PAC) - vacuum aspiration (MVA)/surgical", "PAC Surgical", "primary"],
  ["81", "Medical consultation on other SRH problems (nurse, CO)", "Medical Consult", "primary"],
  ["82", "Gynecological consultation on other SRH problems", "GYN Consult", "primary"],
  ["91", "Cervical cancer screening", "Cervical Cancer Screen", "primary"],
  ["99", "GBV, first assessment, PEP, management STIs, referral", "GBV Services", "primary"]
]

SERVICES.each do |(code, description, short_desc, type)|
  Service.where(code: code).first_or_create(
    description: description, short_description: short_desc, service_type: type)
end

puts "There are #{Service.count} services."

