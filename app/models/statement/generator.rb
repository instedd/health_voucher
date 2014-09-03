class Statement::Generator
  attr_accessor :clinic, :until_date

  def initialize(clinic, until_date)
    @clinic = clinic
    @until_date = until_date
  end

  def find_transactions
    return [] if @clinic.site.training?

    Transaction.joins(:authorization => :provider).
      where(:status => :unpaid).
      where(:statement_id => nil).
      where('transactions.created_at <= ?', @until_date.end_of_day).
      where('providers.clinic_id = ?', @clinic.id).
      includes(:authorization => [:card => :site, :provider => :site]).
      readonly(false).
      reject { |txn| txn.training? }
  end

  def generate
    txns = find_transactions
    return nil if txns.empty?

    Statement.transaction do
      stmt = @clinic.statements.create! until: @until_date
      txns.each do |txn|
        txn.update_attribute :statement, stmt
      end
      stmt.compute_total
      stmt.save
      stmt
    end
  end
end

