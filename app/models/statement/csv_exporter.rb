class Statement::CsvExporter < CsvExporter
  include CardsHelper

  def initialize(statement)
    @stmt = statement
  end

  def export
    headers "# Txn ID", "Date", "Provider Code", "Provider Name", "Service Code", "Service", "AGEP ID", "Voucher", "Amount"
    generate do |csv|
      @stmt.transactions.for_listing.each do |txn|
        csv << [txn.id, txn.created_at, txn.provider.code, txn.provider.name, txn.service.code, txn.service.description, txn.patient.agep_id, card_serial_number(txn.card), txn.amount]
      end
    end
  end
end

