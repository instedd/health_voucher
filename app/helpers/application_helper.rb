module ApplicationHelper
  def error_messages_for(model)
    model.errors.full_messages.join('. ')
  end
end
