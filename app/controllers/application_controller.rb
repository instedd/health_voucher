class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery

  before_filter :set_cache_buster
  before_filter :authenticate_user!

  # after_filter :verify_authorized,  except: :index
  # after_filter :verify_policy_scoped, only: :index
 
  rescue_from Pundit::NotAuthorizedError, with: :permission_denied
  
  private

  def authenticate_admin!
    unless current_user.admin?
      permission_denied
      false
    end
  end

  def permission_denied
    render :file => "public/401", :status => :unauthorized, :layout => false
  end
  
  # Monkey patch add_breadcrumb to escape HTML entities in the breadcrumb
  # name

  alias_method :old_add_breadcrumb, :add_breadcrumb

  def add_breadcrumb(name, path = nil, options = {})
    if name.is_a?(String) && !name.html_safe?
      name = ERB::Util.html_escape(name)
    end
    old_add_breadcrumb name, path, options
  end

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def log_activity(object, description)
    current_user.log_activity object, description
  end

  def render_csv(content, filename = nil)
    response.headers['Content-type'] = 'text/csv'
    response.headers['Content-disposition'] = "attachment; filename=\"#{filename}\"" unless filename.blank?

    render text: content
  end
end
