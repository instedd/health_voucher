require 'csv'

class Statement::CsvExporter
  include CardsHelper

  def initialize(statement)
    @stmt = statement
  end

  def export
    CSV.generate do |csv|
      csv << ["# Txn ID", "Date", "Provider", "Service", "AGEP ID", "Voucher", "Amount"]
      @stmt.transactions.for_listing.each do |txn|
        csv << [txn.id, txn.created_at, txn.provider.code, txn.service.code, txn.patient.agep_id, card_serial_number(txn.card), txn.amount]
      end
    end
  end
end

