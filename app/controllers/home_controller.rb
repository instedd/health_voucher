class HomeController < ApplicationController
  def index
    if current_user.admin?
      redirect_to sites_path
    elsif current_user.site.present?
      redirect_to site_mentors_path(current_user.site)
    else
      permission_denied
    end
  end
end
