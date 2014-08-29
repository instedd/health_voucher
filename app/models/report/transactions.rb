class Report::Transactions < Report
  attr_reader :site_id

  group_by :site, :clinic

  def self.build params
    new(params).build
  end

  def initialize(params)
    super

    @site_id = params[:site_id]
  end

  def build
    if by_site?
      build_by_site
    else
      build_by_clinic
    end
    self
  end

  def title
    if by_site?
      "Transactions by AGEP ID site"
    else
      "Transactions by clinic in #{Site.find(site_id).name}"
    end
  end

  def column_keys
    if by_site?
      [:site_name]
    else
      [:clinic_name]
    end + [:txn_count, :unique_visitors]
  end

  def column_titles
    if by_site?
      ["AGEP ID Site"]
    else
      ["Clinic"]
    end + ["Transactions #{humanized_date_range}", "Unique visitors"]
  end

  private

  def build_by_site
    since_when = 30.days.ago
    patients_with_recent_visits = Patient.
      joins(:current_card => {:authorizations => :transaction}).
      joins(:mentor).
      uniq.
      select(['patients.id', 'mentors.site_id AS site_id'])
    patients_with_recent_visits = add_date_criteria(patients_with_recent_visits, 'transactions.created_at')

    site_visits = patients_with_recent_visits.map do |patient| patient.site_id end
    transactions = Transaction.
      joins(:authorization => {:card => {:patient => :mentor}}).
      select(['mentors.site_id AS site_id', 'COUNT(*) AS txn_count']).
      group('site_id')
    transactions = add_date_criteria(transactions, 'transactions.created_at')

    txns_per_site = Hash[transactions.map do |txn|
      [txn.site_id, txn.txn_count]
    end]
    sites = Site.order(:name)
    @data = sites.map do |site|
      {
        :site_id => site.id,
        :site_name => site.name,
        :txn_count => txns_per_site[site.id] || 0,
        :unique_visitors => site_visits.count { |id| id == site.id }
      }
    end
    @totals = totalize @data, [:unique_visitors, :txn_count]
  end

  def build_by_clinic
    patients_with_recent_visits = Patient.
      joins(:current_card => {:authorizations => [:transaction, :provider]}).
      uniq.
      select(['patients.id', 'providers.clinic_id AS clinic_id'])
    patients_with_recent_visits = add_date_criteria(patients_with_recent_visits, 'transactions.created_at')

    visited_clinics = patients_with_recent_visits.map do |patient| patient.clinic_id end
    transactions = Transaction.
      joins(:authorization => [:provider => :clinic]).
      where('clinics.site_id' => site_id).
      select(['providers.clinic_id AS clinic_id', 'COUNT(*) AS txn_count']).
      group('clinic_id')
    transactions = add_date_criteria(transactions, 'transactions.created_at')

    txns_per_clinic = Hash[transactions.map do |txn|
      [txn.clinic_id, txn.txn_count]
    end]
    clinics = Clinic.joins(:site).where('sites.id' => site_id)
    @data = clinics.map do |clinic|
      {
        :clinic_name => clinic.name,
        :txn_count => txns_per_clinic[clinic.id] || 0,
        :unique_visitors => visited_clinics.count { |id| id == clinic.id }
      }
    end
    @totals = totalize @data, [:unique_visitors, :txn_count]
  end
end

