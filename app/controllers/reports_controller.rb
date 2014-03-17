class ReportsController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :add_breadcrumbs

  def card_allocation
    since_when = 7.days.ago
    patients_with_recent_uses = Patient.
      joins(:current_card => {:authorizations => :transaction}, :mentor => []).
      where('transactions.created_at > ?', since_when).
      uniq.
      select(['patients.id', 'mentors.site_id AS site_id'])
    sites_for_uses = patients_with_recent_uses.map(&:site_id)
    sites = Site.with_patient_counts.order(:name)
    @data = sites.map do |site|
      {
        :name => site.name,
        :patient_count => site.patient_count,
        :patients_with_card => site.patient_count - site.patients_without_card,
        :patients_without_card => site.patients_without_card,
        :patients_with_recent_card_uses => sites_for_uses.count { |id| id == site.id }
      }
    end
    @totals = totalize @data, [
      :patient_count,
      :patients_with_card,
      :patients_without_card,
      :patients_with_recent_card_uses
    ]
  end

  def transactions
    if params[:by] == 'clinic'
      transactions_per_clinic
    else
      transactions_per_site
    end
  end

  def services
    default_date = 1.month.ago.beginning_of_month
    params[:month] ||= default_date.month
    params[:year] ||= default_date.year
    start_date = Date.new(params[:year].to_i, params[:month].to_i, 1) rescue default_date
    end_date = start_date.end_of_month

    transactions = Transaction.
      joins(:authorization => [:provider => :clinic]).
      where('transactions.created_at >= ?', start_date).
      where('transactions.created_at <= ?', end_date)

    if params[:by] != 'clinic'
      transactions = transactions.
        select(['authorizations.service_id AS service_id', 
                'clinics.site_id AS col_id',
                'COUNT(*) AS txn_count']).
        group('service_id, col_id')
      @columns = Site.order(:name).map do |site|
        { id: site.id, name: site.name }
      end
    else
      transactions = transactions.
        where('clinics.site_id' => params[:site_id]).
        select(['authorizations.service_id AS service_id', 
                'clinics.id AS col_id',
                'COUNT(*) AS txn_count']).
        group('service_id, col_id')
      @columns = Clinic.where(:site_id => params[:site_id]).order(:name).map do |clinic|
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
  end

  def clinics
    default_date = 1.month.ago.beginning_of_month
    params[:month] ||= default_date.month
    params[:year] ||= default_date.year
    start_date = Date.new(params[:year].to_i, params[:month].to_i, 1) rescue default_date
    end_date = start_date.end_of_month

    transactions = Transaction.
      joins(:authorization => [:provider => :clinic]).
      where('transactions.created_at >= ?', start_date).
      where('transactions.created_at <= ?', end_date).
      select(['clinics.id AS clinic_id',
              'COUNT(*) as txn_count']).
      group('clinic_id')

    transactions = transactions.where('clinics.site_id' => params[:site_id]) if params[:site_id].present?
    transactions_count = Hash[transactions.map do |row|
      [row[:clinic_id], row[:txn_count]]
    end]

    clinics = Clinic.includes(:site).order(:name)
    clinics = clinics.where(:site_id => params[:site_id]) if params[:site_id].present?

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
  end

  private

  def transactions_per_site
    since_when = 30.days.ago
    patients_with_recent_visits = Patient.
      joins(:current_card => {:authorizations => [:transaction, :provider => :clinic]}).
      where('transactions.created_at > ?', since_when).
      uniq.
      select(['patients.id', 'clinics.site_id AS site_id'])
    site_visits = patients_with_recent_visits.map do |patient| patient.site_id end
    transactions = Transaction.
      joins(:authorization => [:provider => :clinic]).
      where('transactions.created_at > ?', since_when).
      select(['clinics.site_id AS site_id', 'COUNT(*) AS txn_count']).
      group('site_id')
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
    @report_partial = 'transactions_per_site'
  end

  def transactions_per_clinic
    since_when = 30.days.ago
    patients_with_recent_visits = Patient.
      joins(:current_card => {:authorizations => [:transaction, :provider]}).
      where('transactions.created_at > ?', since_when).
      uniq.
      select(['patients.id', 'providers.clinic_id AS clinic_id'])
    visited_clinics = patients_with_recent_visits.map do |patient| patient.clinic_id end
    transactions = Transaction.
      joins(:authorization => [:provider => :clinic]).
      where('transactions.created_at > ?', since_when).
      where('clinics.site_id' => params[:site_id]).
      select(['providers.clinic_id AS clinic_id', 'COUNT(*) AS txn_count']).
      group('clinic_id')
    txns_per_clinic = Hash[transactions.map do |txn|
      [txn.clinic_id, txn.txn_count]
    end]
    clinics = Clinic.joins(:site).
      where('sites.id' => params[:site_id])
    @data = clinics.map do |clinic|
      {
        :clinic_name => clinic.name,
        :txn_count => txns_per_clinic[clinic.id] || 0,
        :unique_visitors => visited_clinics.count { |id| id == clinic.id }
      }
    end
    @totals = totalize @data, [:unique_visitors, :txn_count]
    @report_partial = 'transactions_per_clinic'
  end

  def totalize(data, keys)
    @data.reduce({}) do |memo, row|
      keys.each do |key|
        if row[key].is_a?(Array)
          if memo[key].nil?
            memo[key] = row[key].clone
          else
            memo[key] = memo[key].zip(row[key]).map { |x,y| x + y }
          end
        else
          memo[key] = (memo[key] || 0) + row[key]
        end
      end
      memo
    end
  end

  def add_breadcrumbs
    @show_breadcrumb = true
    add_breadcrumb 'Reports', reports_path
  end
end
