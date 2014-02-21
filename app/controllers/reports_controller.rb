class ReportsController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :add_breadcrumbs

  def agep_ids
    sites = Site.with_patient_counts
    @data = sites.map do |site|
      { 
        :name => site.name,
        :patient_count => site.patient_count,
        :patients_with_card => site.patient_count - site.patients_without_card,
        :patients_without_card => site.patients_without_card
      }
    end
    @totals = totalize @data, [:patient_count, :patients_with_card, :patients_without_card]
  end

  def voucher_usage
    since_when = 7.days.ago
    patients_with_recent_uses = Patient.
      joins(:current_card => {:authorizations => :transaction}, :mentor => []).
      where('transactions.created_at > ?', since_when).
      uniq.
      select(['patients.id', 'mentors.site_id AS site_id'])
    sites_for_uses = patients_with_recent_uses.map(&:site_id)
    sites = Site.with_patient_counts
    @data = sites.map do |site|
      {
        :name => site.name,
        :patients_with_card => site.patient_count - site.patients_without_card,
        :patients_with_recent_card_uses => sites_for_uses.count { |id| id == site.id }
      }
    end
    @totals = totalize @data, [:patients_with_card, :patients_with_recent_card_uses]
  end

  private

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
