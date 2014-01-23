require 'csv'

class Batch::CsvExporter < CsvExporter
  def initialize(batch)
    @batch = batch
  end

  def export
    headers ["# Serial number", "Check digit",  
             column_titles(Card::PRIMARY_SERVICES, 'primary'),
             column_titles(Card::SECONDARY_SERVICES, 'secondary')].flatten
    generate do |csv|
      @batch.cards_with_vouchers.each do |card|
        csv << [card.serial_number, card.check_digit,
                card.primary_services.map(&:code),
                card.secondary_services.map(&:code)].flatten
      end
    end
  end

  private

  def column_titles(count, prefix)
    count.times.map do |i|
      "#{prefix.capitalize} services position #{i + 1}"
    end
  end
end

