class HomeController < ApplicationController
  def index
  end

  def clinics
    if Site.count > 0
      redirect_to site_clinics_path(Site.first)
    else
      redirect_to sites_path
    end
  end
end
