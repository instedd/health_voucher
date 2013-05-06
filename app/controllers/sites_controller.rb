class SitesController < ApplicationController
  def index
    @sites = Site.all
  end

  def new
    @site = Site.new
  end

  def create
    @site = Site.new(params[:site])
    if @site.save
      redirect_to sites_path, notice: 'Site was registered successfully'
    else
      render :new
    end
  end
end
