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

  def many_check_box_tags(field_name, choices, selected, options={})
    field_name = "#{field_name}[]"
    all = (options[:allow_blank].nil? || options[:allow_blank]) && selected.nil?
    selected ||= []
    result = choices.map do |choice|
      choice_name, choice_value = choice
      id = "#{field_name.underscore}_#{choice_value}"
      label_tag do
        check_box_tag(field_name, choice_value, all || selected.include?(choice_value.to_s), :id => id) + choice_name
      end
    end

    if options[:allow_blank].nil? || options[:allow_blank]
      result << hidden_field_tag(field_name, '')
    end
    
    if options[:select_all].nil? || options[:select_all]
      field_name = "select_all_#{field_name.underscore}"
      result.unshift(
        label_tag do
          check_box_tag(field_name, 1, false, :class => 'filtersSelectAll') +\
          content_tag(:span, 'Select all')
        end
      )
    end

    result.join(options[:separator] || '<br/>').html_safe
  end
  
end
