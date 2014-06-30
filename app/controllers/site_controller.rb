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
      if current_user.admin? || current_user.auditor?
        redirect_to sites_path
      else
        permission_denied
      end
    else
      permission_denied if current_user.site_manager? && @site.manager != current_user
    end
  end
end

