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
      joins(:authorization => [:provider]).
      where('transactions.created_at > ?', since_when).
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
        memo[key] = (memo[key] || 0) + row[key]
      end
      memo
    end
  end

  def add_breadcrumbs
    @show_breadcrumb = true
    add_breadcrumb 'Reports', reports_path
  end
end
