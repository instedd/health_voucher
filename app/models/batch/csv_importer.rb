require 'csv'

class Batch::CsvImporter
  ANY_ROW_FIELDS = 2 + Card::ANY_SERVICES
  ANY_VOUCHER_RANGE = 2..(ANY_ROW_FIELDS-1)

  SPLIT_ROW_FIELDS = 2 + Card::PRIMARY_SERVICES + Card::SECONDARY_SERVICES
  SPLIT_VOUCHER_RANGE = 2..(SPLIT_ROW_FIELDS-1)

  def initialize(name)
    @name = name
    @first_sn = nil
    @last_sn = nil
    @cards = []
    @type = nil
    @voucher_range = nil
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
      if @type.nil?
        # first row determines what type of card we get
        if row.size == SPLIT_ROW_FIELDS
          @type = :split
          @voucher_range = SPLIT_VOUCHER_RANGE
        else
          @type = :any
          @voucher_range = ANY_VOUCHER_RANGE
        end
      elsif @type == :split
        unless row.size == SPLIT_ROW_FIELDS
          raise RuntimeError, "CSV has invalid number of field at line #{line}"
        end
      else
        unless row.size == ANY_ROW_FIELDS
          raise RuntimeError, "CSV has invalid number of field at line #{line}"
        end
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
      @voucher_range.each do |index|
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
    raise RuntimeError, "inconsistency in the number of vouchers" if vouchers.count != @voucher_range.count * qty
  end

  def create_batch
    sn = @first_sn
    qty = @last_sn - @first_sn + 1

    Batch.transaction do
      batch = Batch.create! name: @name, initial_serial_number: sn, quantity: qty
      @cards.each do |codes|
        card = batch.cards.create! serial_number: sn
        case @type
        when :split
          create_split_vouchers(card, codes)
        when :any
          create_any_vouchers(card, codes)
        end
        sn += 1
      end
      batch
    end
  end

  def create_any_vouchers(card, codes)
    codes[0..Card::ANY_SERVICES - 1].each do |code|
      card.vouchers.create! :service_type => :any, :code => code
    end
  end

  def create_split_vouchers(card, codes)
    codes[0..Card::PRIMARY_SERVICES - 1].each do |code|
      card.vouchers.create! :service_type => :primary, :code => code
    end
    codes[Card::PRIMARY_SERVICES..-1].each do |code|
      card.vouchers.create! :service_type => :secondary, :code => code
    end
  end
end
