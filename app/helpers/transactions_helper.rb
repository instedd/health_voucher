module TransactionsHelper
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

  def filter_empty?
    filter_params.values.all?(&:blank?)
  end

  def filter_params
    %w(site_id clinic_id status since until).inject({}) do |result, key|
      result[key] = params[key]
      result
    end
  end

  def clear_filter_transactions_path
    transactions_path
  end

  def sort_column
    params[:sort]
  end

  def sort_direction
    params[:direction]
  end

  def sort_header(column, title = nil)
    title ||= column.to_s.titleize
    page_number = params[:page]
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    options = filter_params.merge({
      :sort => column, 
      :direction => direction, 
      :page => params[:page]
    })
    content_tag :th, (link_to(title, options) + '<span></span>'.html_safe), :class => css_sort_class_for(column)
  end
end
