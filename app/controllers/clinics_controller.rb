class ClinicsController < SiteController
  before_filter :load_clinic, :except => [:index, :create]
  before_filter :add_breadcrumbs

  def index
    authorize Clinic
    @clinics = policy_scope(@site.clinics).order(:name)

    respond_to do |format|
      format.html {
        @clinic = Clinic.new
        @clinic.site = @site
      }
      format.csv {
        exporter = Site::ClinicsCsvExporter.new(@clinics)
        render_csv exporter.export, "#{@site.name}-clinics.csv"
      }
    end
  end

  def create
    @clinic = @site.clinics.create(clinic_params)
    authorize @clinic
    if @clinic.valid?
      flash[:notice] = 'Clinic created'
    end
  end

  def show
    @providers = @clinic.providers.order(:name)

    respond_to do |format|
      format.html {
        @provider = Provider.new
        @provider.clinic = @clinic
      }
      format.csv {
        exporter = Clinic::ProvidersCsvExporter.new(@providers)
        render_csv exporter.export, "#{@site.name}-#{@clinic.name}-providers.csv"
      }
    end
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
    authorize @clinic
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

  def clinic_params
    params.require(:clinic).permit(:name)
  end
end
