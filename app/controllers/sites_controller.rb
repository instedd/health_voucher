class SitesController < ApplicationController
  before_filter :add_breadcrumbs

  def index
    @sites = Site.all
  end

  def new
    add_breadcrumb 'New site', nil
    @site = Site.new
  end

  def create
    @site = Site.new(params[:site])
    if @site.save
      redirect_to sites_path, notice: 'Site was registered successfully'
    else
      add_breadcrumb 'New site', nil
      render :new
    end
  end

  def edit
    @site = Site.find(params[:id])
    add_breadcrumb @site.name, nil
  end

  def update
    @site = Site.find(params[:id])
    @site.update_attributes params[:site]
    if @site.save
      redirect_to sites_path, notice: 'Site was updated successfully'
    else
      add_breadcrumb @site.name, nil
      render :edit
    end
  end

  private

  def add_breadcrumbs
    @show_breadcrumb = true
    add_breadcrumb 'Sites', sites_path
  end
end
