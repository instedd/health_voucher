class Batch::Generator
  def initialize(batch, type = :any)
    @batch = batch
    @type = type
  end

  def generate!
    from = @batch.first_serial_number
    to = @batch.last_serial_number
    (from..to).each do |sn|
      unless Card.find_by_serial_number(sn.to_serial_number)
        Card.transaction do
          build_card(sn)
        end
      end
    end
  end

  def vouchers_per_card
    case @type
    when :split
      Card::PRIMARY_SERVICES + Card::SECONDARY_SERVICES
    when :any
      Card::ANY_SERVICES
    end
  end

  private

  def voucher_type_counts
    case @type
    when :split
      [[:primary, Card::PRIMARY_SERVICES], [:secondary, Card::SECONDARY_SERVICES]]
    when :any
      [[:any, Card::ANY_SERVICES]]
    end
  end

  def build_card(serial_number)
    card = @batch.cards.create! serial_number: serial_number

    voucher_type_counts.each do |type, count|
      count.times do
        begin
          voucher = card.vouchers.create :service_type => type, 
            :code => Card::Code.generate_voucher_code
        end while voucher.id.nil?
      end
    end
  end
end

