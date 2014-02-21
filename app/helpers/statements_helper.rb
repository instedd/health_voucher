module StatementsHelper
  def statement_status_filter_options(current = nil)
    options_for_select([['(Any status)', '']] + Statement.status.options, current)
  end

  def statements_filter_empty?
    %w(stmt_id site_id clinic_id status since until txn_from txn_to).all? do |key|
      params[key].blank?
    end
  end

  def clear_filter_statements_path
    statements_path(sort: params[:sort], direction: params[:direction])
  end
end
