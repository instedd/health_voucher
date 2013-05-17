namespace :faker do
  desc "Create a number of random transactions using registered cards, services and providers"
  task :gentxn, [:n] => :environment do |t, args|
    n = args[:n].to_i

    Timecop.travel (5 * n).minutes.ago

    puts "Trying to generate #{n} transactions..."
    n.times.each do
      Timecop.travel rand(4..6).minutes
      provider = Provider.where(:enabled => true).to_a.sample
      patient = Patient.with_card.to_a.sample
      card = patient.current_card
      service = provider.clinic.enabled_clinic_services.sample.service
      voucher = card.unused_vouchers(service.service_type).first

      begin
        processor = Authorization::Processor.new(provider, patient, card)
        processor.add_services([service])
        processor.authorize
      rescue Exception => e
        puts "Failed to authorize #{service.code} for provider #{provider.code} for AGEP ID #{patient.agep_id} with voucher #{card.full_serial_number}: #{processor.error_message}"
        next
      end

      begin
        confirmer = Transaction::Processor.new(service, voucher)
        confirmer.confirm
      rescue Exception => e
        puts "Failed to confirm #{service.code} for provider #{provider.code} for AGEP ID #{patient.agep_id} with voucher #{card.full_serial_number} using PIN #{voucher.code}: #{confirmer.error_message}"
      end
    end

    Timecop.return
  end
end

