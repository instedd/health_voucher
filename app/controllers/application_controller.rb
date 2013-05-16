class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!

  private

  def authenticate_admin!
    unless current_user.admin?
      permission_denied
      false
    end
  end

  def permission_denied
    render :file => "public/401.html", :status => :unauthorized, :layout => false
  end
end
