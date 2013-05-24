class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_cache_buster
  before_filter :authenticate_user!

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
end
