class Report::Services < Report
  attr_reader :site_id, :columns

  group_by :site, :clinic

  def self.build params
    new(params).build
  end

  def initialize(params)
    super

    @site_id = params[:site_id]
  end

  def build
    transactions = Transaction.joins(:authorization => [:card => {:patient => :mentor}, :provider => :clinic])
    transactions = add_date_criteria(transactions, 'transactions.created_at')

    if by_site?
      transactions = transactions.
        select(['authorizations.service_id AS service_id',
                'mentors.site_id AS col_id',
                'COUNT(*) AS txn_count']).
        group('service_id, col_id')
      @columns = Site.order(:name).map do |site|
        { id: site.id, name: site.name }
      end
    else
      transactions = transactions.
        where('clinics.site_id' => site_id).
        select(['authorizations.service_id AS service_id',
                'clinics.id AS col_id',
                'COUNT(*) AS txn_count']).
        group('service_id, col_id')
      @columns = Clinic.where(:site_id => site_id).order(:name).map do |clinic|
        { id: clinic.id, name: clinic.name }
      end
    end
    transaction_counts = Hash[transactions.map do |txn|
      [[txn[:service_id], txn[:col_id]], txn[:txn_count]]
    end]

    @data = Service.order(:code).map do |service|
      cols = @columns.map do |col|
        transaction_counts[[service.id, col[:id]]] || 0
      end
      {
        id: service.id,
        service_type: service.service_type,
        description: service.description,
        cols: cols,
        row_total: cols.sum
      }
    end.sort_by do |row|
      row[:row_total]
    end.reverse

    @totals = totalize @data, [:cols, :row_total]

    self
  end

  def title
    "Most frequently accessed services by " + \
      if by_site?
        "AGEP ID site"
      else
        "clinic in #{Site.find(site_id).name}"
      end
  end

  def column_titles
    ["Service", "Total transactions #{humanized_date_range}", @columns.map {|col| col[:name]}].flatten
  end

  def column_keys
    [:description, :row_total, :cols]
  end
end

