require 'csv'

class Batch::CsvExporter
  def initialize(batch)
    @batch = batch
  end

  def export
    CSV.generate do |csv|
      csv << ["# Serial number", 
              column_titles(Card::PRIMARY_SERVICES, 'primary'),
              column_titles(Card::SECONDARY_SERVICES, 'secondary')].flatten
      @batch.cards_with_vouchers.each do |card|
        csv << [card.full_serial_number, 
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

