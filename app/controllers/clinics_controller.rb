class ClinicsController < SiteController
  before_filter :authenticate_admin!
  before_filter :load_clinic, :except => [:index, :create]
  before_filter :add_breadcrumbs

  def index
    @clinics = @site.clinics.order(:name)
    @clinic = Clinic.new
    @clinic.site = @site
  end

  def create
    @clinic = @site.clinics.create(params[:clinic])
    if @clinic.valid?
      flash[:notice] = 'Clinic created'
    end
  end

  def show
    @provider = Provider.new
    @provider.clinic = @clinic
  end

  def services
  end

  def destroy
    @clinic.destroy
    if @clinic.destroyed?
      flash[:notice] = "The clinic was removed"
    else
      flash[:alert] = "The clinic could not be removed: #{@clinic.errors.full_messages.join}"
    end
    redirect_to site_clinics_path(@site)
  end

  def toggle_service
    @service = Service.find(params[:service_id])
    @clinic_service = @clinic.clinic_service_for(@service)
    @clinic_service.enabled = params[:enabled].present?
    @clinic_service.save(validate: false)
    head :ok
  end

  def set_service_cost
    @service = Service.find(params[:service_id])
    @clinic_service = @clinic.clinic_service_for(@service)
    @clinic_service.cost = params[:cost]
    @clinic_service.save || @clinic_service.reload
    respond_to do |format|
      format.js
      format.html {
        redirect_to site_clinic_path(@site, @clinic)
      }
    end
  end

  private

  def load_clinic
    @clinic = @site.clinics.find(params[:id])
  end

  def add_breadcrumbs
    @show_breadcrumb = true
    add_breadcrumb 'Sites', sites_path
    add_breadcrumb @site.name, @site
    add_breadcrumb 'Clinics', site_clinics_path(@site)
    unless @clinic.nil?
      add_breadcrumb @clinic.name, site_clinic_path(@site, @clinic)
    end
  end
end
