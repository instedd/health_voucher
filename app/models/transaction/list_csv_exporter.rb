class Transaction::ListCsvExporter < CsvExporter
  include CardsHelper

  attr_reader :transactions

  def initialize(transactions)
    @transactions = transactions
  end

  def export
    headers "# ID", "Date", "Clinic", "Provider Code", "Service Code", "AGEP Site", "AGEP ID", "Voucher", "Statement", "Amount", "Status", "Comment"
    generate do |csv|
      transactions.each do |txn|
        csv << [txn.id, txn.created_at, txn.clinic.name,
                txn.provider.code, txn.service.code,
                (txn.patient.site.name rescue nil), (txn.patient.agep_id rescue nil),
                card_serial_number(txn.card), txn.statement_id,
                txn.amount, txn.status, txn.comment]
      end
    end
  end
end

