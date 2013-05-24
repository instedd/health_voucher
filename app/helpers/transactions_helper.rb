module TransactionsHelper
  def filter_empty?
    %w(site_id clinic_id status since until).all? do |key|
      params[key].blank?
    end
  end

  def sites_filter_options(current = nil)
    options_for_select([['(All Sites)', '']]) + sites_for_select(current)
  end

  def clinics_filter_options(site_id, current = nil)
    result = options_for_select([['(All Clinics)', '']])
    if site_id.present?
      result << clinics_for_select(Site.find(site_id), current)
    end
    result
  end

  def status_filter_options(current = nil)
    options_for_select([['(Any status)', '']] + Transaction.status.options, current)
  end

  def clear_filter_transactions_path
    transactions_path
  end
end
