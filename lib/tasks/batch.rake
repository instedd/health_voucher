namespace :batch do
  desc "Create and generate a batch of cards"
  task :generate, [:name, :initial, :quantity] => :environment do |t, args|
    name = args[:name]
    initial_sn = args[:initial].to_serial_number
    qty = args[:quantity].to_i

    puts "Creating batch #{name}, #{qty} cards starting from #{initial_sn}"
    begin
      batch = Batch.new name: name, initial_serial_number: initial_sn, quantity: qty
      batch.save!

      generator = Batch::Generator.new(batch)
      generator.generate!

      puts "Batch generated with id #{batch.id}"

    rescue Exception => e
      puts "Error creating batch: #{e}"
    end
  end

  desc "List available batches"
  task :list => :environment do |t, args|
    puts "Id     Name                                             First SN   Qty"
    puts "-" * 70
    Batch.order("initial_serial_number").all.each do |batch|
      puts "#{batch.id.to_s.ljust(6)} #{batch.name.truncate(50).ljust(50)} " + 
           "#{batch.initial_serial_number} #{batch.quantity.to_s.rjust(5)}"
    end
  end

  desc "Export card serial numbers and voucher codes for a given batch"
  task :export, [:id] => :environment do |t, args|
    batch = Batch.find(args[:id])
    puts Batch::CsvExporter.new(batch).export
  end

  desc "Import cards in CSV format from standard input and create a batch of the given name"
  task :import, [:name] => :environment do |t, args|
    text = STDIN.read
    begin
      batch = Batch::CsvImporter.new(args[:name]).import(text)
      puts "#{batch.quantity} cards imported to batch #{batch.id}, starting at #{batch.initial_serial_number}"
    rescue ActiveRecord::RecordInvalid, RuntimeError => e
      puts "Error importing: #{e}"
    end
  end
end

