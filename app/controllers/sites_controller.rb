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

  def edit
    @site = Site.find(params[:id])
  end

  def update
    @site = Site.find(params[:id])
    @site.update_attributes params[:site]
    if @site.save
      redirect_to sites_path, notice: 'Site was updated successfully'
    else
      render :edit
    end
  end

  def assign_cards
    @site = Site.find(params[:id])
  end
end
