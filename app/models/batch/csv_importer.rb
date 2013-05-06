require 'csv'

class Batch::CsvImporter
  ROW_FIELDS = 2 + Card::PRIMARY_SERVICES + Card::SECONDARY_SERVICES
  VOUCHER_RANGE = 2..(ROW_FIELDS-1)

  def initialize(name)
    @name = name
    @first_sn = nil
    @last_sn = nil
    @cards = []
  end

  def import(text)
    csv = CSV.parse(text, :headers => true)
    read_and_validate_csv(csv)

    create_batch if @cards.any?
  end

  private

  def read_and_validate_csv(csv)
    vouchers = Set.new  # to check for duplicates
    line = 2  # first line is the CSV header

    csv.each do |row|
      unless row.size == ROW_FIELDS
        raise RuntimeError, "CSV has invalid number of field at line #{line}"
      end

      serial_number = row[0].to_i
      check_digit = row[1]
      unless Card::Damm.generate(serial_number) == check_digit
        raise RuntimeError, "invalid check digit at line #{line}" 
      end

      if @last_sn.nil?
        @last_sn = serial_number
        @first_sn = serial_number
      elsif serial_number != @last_sn + 1
        raise RuntimeError, "serial numbers are not consecutive at line #{line}" 
      else
        @last_sn = serial_number
      end

      codes = []
      VOUCHER_RANGE.each do |index|
        code = row[index]
        if vouchers.include?(code)
          raise RuntimeError, "duplicate voucher code detected at line #{line}"
        end
        unless Card::Code.check(code)
          raise RuntimeError, "invalid voucher code at line #{line}"
        end
        vouchers << code
        codes << code
      end
      @cards << codes

      line += 1
    end

    return if @first_sn.nil?   # nothing to import

    qty = @last_sn - @first_sn + 1
    raise RuntimeError, "inconsistency in the number of cards" if qty != @cards.count
    raise RuntimeError, "inconsistency in the number of vouchers" if vouchers.count != 13 * qty
  end

  def create_batch
    sn = @first_sn
    qty = @last_sn - @first_sn + 1

    Batch.transaction do
      batch = Batch.create! name: @name, initial_serial_number: sn, quantity: qty
      @cards.each do |codes|
        card = batch.cards.create! serial_number: sn
        codes[0..Card::PRIMARY_SERVICES - 1].each do |code|
          card.vouchers.create! :service_type => :primary, :code => code
        end
        codes[Card::PRIMARY_SERVICES..-1].each do |code|
          card.vouchers.create! :service_type => :secondary, :code => code
        end
        sn += 1
      end
      batch
    end
  end
end
