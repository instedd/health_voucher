class Batch::Generator
  def initialize(batch)
    @batch = batch
  end

  def generate!
    from = @batch.initial_serial_number.to_i
    to = from + @batch.quantity - 1
    Batch.transaction do
      (from..to).each do |sn|
        unless Card.find_by_serial_number(sn.to_serial_number)
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

