module ApplicationHelper
  def error_messages_for(model)
    model.errors.full_messages.join('. ')
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
    options = params.merge({
      :sort => column, 
      :direction => direction 
    })
    content_tag :th, (link_to(title, options) + '<span></span>'.html_safe), :class => css_sort_class_for(column)
  end

  def humanize_boolean(value)
    if value
      "yes"
    else
      "no"
    end
  end
end
