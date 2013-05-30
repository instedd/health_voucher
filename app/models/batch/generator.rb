class Batch::Generator
  def initialize(batch)
    @batch = batch
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

  private

  def build_card(serial_number)
    card = @batch.cards.create! serial_number: serial_number

    [[:primary, Card::PRIMARY_SERVICES], 
     [:secondary, Card::SECONDARY_SERVICES]].each do |type, count|
      count.times do
        begin
          voucher = card.vouchers.create :service_type => type, 
            :code => Card::Code.generate_voucher_code
        end while voucher.nil?
      end
    end
  end
end

