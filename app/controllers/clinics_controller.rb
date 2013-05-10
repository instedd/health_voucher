class ClinicsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_site
  before_filter :add_breadcrumbs

  def index
  end

  def create
    @clinic = @site.clinics.create(params[:clinic])
    if @clinic.valid?
      redirect_to site_clinic_path(@clinic), notice: 'Clinic was created'
    else
      redirect_to site_clinics_path(@site), 
        alert: "Error creating clinic: #{@clinic.errors.full_messages.join(', ')}"
    end
  end

  def show
    @clinic = @site.clinics.find(params[:id])
    add_breadcrumb @clinic.name, site_clinic_path(@site, @clinic)
  end

  def destroy
    @clinic = @site.clinics.find(params[:id])
    @clinic.destroy
    if @clinic.destroyed?
      flash[:notice] = "The clinic was removed"
    else
      flash[:alert] = "The clinic could not be removed: #{@clinic.errors.full_messages.join}"
    end
    redirect_to site_clinics_path(@site)
  end

  private

  def load_site
    @site = Site.find(params[:site_id])
    @clinics = @site.clinics.order(:name)
  end

  def add_breadcrumbs
    @show_breadcrumb = true
    add_breadcrumb 'Sites', sites_path
    add_breadcrumb @site.name, sites_path
    add_breadcrumb 'Clinics', site_clinics_path(@site)
  end
end
