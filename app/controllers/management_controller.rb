class ManagementController < ApplicationController
  before_filter :load_site

  def index
  end

  private

  def load_site
    if params[:site_id]
      @site = Site.find(params[:site_id])
    else
      @site = Site.first
    end
  end
end
