class Report::Clinics < Report
  attr_reader :site_id

  def self.build params
    new(params).build
  end

  def initialize(params)
    super

    @site_id = params[:site_id]
  end

  def build
    transactions = Transaction.
      joins(:authorization => [:provider => :clinic]).
      select(['clinics.id AS clinic_id',
              'COUNT(*) as txn_count']).
      group('clinic_id')
    transactions = add_date_criteria(transactions, 'transactions.created_at')

    transactions = transactions.where('clinics.site_id' => site_id) if site_id.present?
    transactions_count = Hash[transactions.map do |row|
      [row[:clinic_id], row[:txn_count]]
    end]

    clinics = Clinic.includes(:site).order(:name)
    clinics = clinics.where(:site_id => site_id) if site_id.present?

    @data = clinics.map do |clinic|
      {
        id: clinic.id,
        name: clinic.name,
        site_name: clinic.site.name,
        row_count: transactions_count[clinic.id] || 0
      }
    end.sort_by do |row|
      row[:row_count]
    end.reverse

    @totals = totalize @data, [:row_count]

    self
  end
end

