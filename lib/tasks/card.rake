namespace :card do

  Primary = "P"
  Secondary = "S"

  task :generate,[:n] => :environment do | t, args|

    i=0

    while i < args[:n].to_i

      begin

      Voucher.transaction do

        card = Card.new :serial_number => CodeGenerator.generate_digits( Card::LengthSerialNumber )
        p card.serial_number
        card.save!

        1.upto( 6 ) do |j|
          v1=card.vouchers.build( :code => CodeGenerator.generate_digits( Voucher::LengthVoucherNumber ), :panel=>Primary )
          p v1.code
          v1.save!
        end

      end

      i += 1

    rescue ActiveRecord::RecordInvalid
      p "Genere una duplicada, no la considero"
    end


    end
  end
end
