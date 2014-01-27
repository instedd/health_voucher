module MessagesHelper
  def message_type_filter_options(current = nil)
    options_for_select([['(All)', ''], 'Authorization', 'Confirmation', 'Unknown'], current)
  end

  def message_status_filter_options(current = nil)
    options_for_select([['(All)', ''], 'Success', 'Failure', 'Error'], current)
  end

  def messages_filter_empty?
    %w(from type status since until).all? do |key|
      params[key].blank?
    end
  end

  def clear_filter_messages_path
    messages_path(sort: params[:sort], direction: params[:direction])
  end
end
