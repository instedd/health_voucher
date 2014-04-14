require 'csv'

class Batch::CsvExporter < CsvExporter
  def initialize(batch)
    @batch = batch
  end

  def export
    card_sample = @batch.cards.first
    if card_sample.present? && card_sample.any_services.count > 0
      export_any_cards
    else
      export_split_cards
    end
  end

  private

  def export_split_cards
    headers ["# Serial number", "Check digit",  
             column_titles(Card::PRIMARY_SERVICES, 'primary'),
             column_titles(Card::SECONDARY_SERVICES, 'secondary')].flatten
    generate(excel_quotes: false) do |csv|
      @batch.cards_with_vouchers.each do |card|
        csv << [card.serial_number, card.check_digit,
                card.primary_services.map(&:code),
                card.secondary_services.map(&:code)].flatten
      end
    end
  end

  def export_any_cards
    headers ["# Serial number", "Check digit",  
             column_titles(Card::ANY_SERVICES)].flatten
    generate(excel_quotes: false) do |csv|
      @batch.cards_with_vouchers.each do |card|
        csv << [card.serial_number, card.check_digit,
                card.any_services.map(&:code)].flatten
      end
    end
  end

  def column_titles(count, prefix = nil)
    count.times.map do |i|
      if prefix.present?
        "#{prefix.capitalize} services position #{i + 1}"
      else
        "Services position #{i + 1}"
      end
    end
  end
end

