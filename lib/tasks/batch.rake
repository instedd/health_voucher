namespace :batch do
  desc "Generate a batch of cards"
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

      puts "OK"

    rescue Exception => e
      puts "Error creating batch: #{e}"
    end
  end
end

