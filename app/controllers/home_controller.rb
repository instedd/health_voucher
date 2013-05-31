class HomeController < ApplicationController
  def index
    if current_user.admin?
      flash.keep
      redirect_to sites_path
    elsif current_user.site.present?
      flash.keep
      redirect_to site_mentors_path(current_user.site)
    else
      sign_out
      redirect_to new_user_session_path, alert: 'Your system access has been revoked. Please contact a system administrator.'
    end
  end
end
