class SiteController < ApplicationController
  before_filter :load_site

  private

  def load_site
    if params[:site_id].present?
      @site = Site.find(params[:site_id])
    else
      @site = current_user.site || Site.first
    end

    if @site.nil?
      redirect_to sites_path
    else
      unless current_user.admin? || @site.manager == current_user
        permission_denied
      end
    end
  end
end

