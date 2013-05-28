module TransactionsHelper
  def status_filter_options(current = nil)
    options_for_select([['(Any status)', '']] + Transaction.status.options, current)
  end

  def transactions_filter_empty?
    %w(txn_id site_id clinic_id status since until).all? do |key|
      params[key].blank?
    end
  end

  def clear_filter_transactions_path
    transactions_path(sort: params[:sort], direction: params[:direction])
  end
end
