class SitesController < ApplicationController
  include PatientsHelper

  before_filter :load_site, :except => [:index, :new, :create, :search]
  before_filter :add_breadcrumbs

  def index
    authorize Site
    @sites = policy_scope(Site).order(:name)
  end

  def show
  end

  def new
    add_breadcrumb 'New site', nil
    @site = Site.new
    authorize @site
  end

  def create
    @site = Site.new(site_params)
    authorize @site
    if @site.save
      redirect_to sites_path, notice: 'Site was registered successfully'
    else
      add_breadcrumb 'New site', nil
      render :new
    end
  end

  def edit
  end

  def update
    @site.update_attributes site_params
    if @site.save
      redirect_to @site, notice: 'Site was updated successfully'
    else
      render :edit
    end
  end

  def assign_cards
    add_breadcrumb 'Assign cards', assign_cards_site_path
    @batches = Batch.have_unassigned_cards.sort_by(&:name)
  end

  def batch_assign_cards
    batch = Batch.find(params[:batch_id])
    qty = params[:quantity].to_i
    result = Batch::CardAllocator.new(batch).assign_to_site(
      @site, params[:first_serial_number], qty)
    if result
      flash[:notice] = "#{result.count} cards assigned to Site's stock"
    else
      flash[:alert] = "Could not assign cards"
    end
    redirect_to assign_cards_site_path(@site)
  end

  def assign_individual_card
    card = Card.find_by_serial_number(params[:serial_number])
    if card
      if Batch::CardAllocator.new(card.batch).assign_to_site(
        @site, params[:serial_number])
        flash[:notice] = "Card assigned to Site's stock"
      else
        flash[:alert] = "Could not assign card"
      end
    else
      flash[:alert] = "Card does not exist"
    end
    redirect_to assign_cards_site_path(@site)
  end

  def return_cards
    cards = Card::Returner.new.return_cards(params[:return_ids])
    redirect_to assign_cards_site_path(@site), notice: "#{cards.size} cards returned"
  end

  def edit_manager
    add_breadcrumb 'Manager', manager_site_path(@site)
    @user = @site.user || @site.build_user
  end

  def update_manager
    @user = @site.user || @site.build_user
    @user.update_for_site_manager user_manager_params
    if @user.save
      @site.update_attribute :user, @user
      log_activity @site, "Manager #{@user.email} was set for site '#{@site.name}'"
      redirect_to @site, notice: 'Site manager was updated'
    else
      add_breadcrumb 'Manager', manager_site_path(@site)
      render 'edit_manager'
    end
  end

  def destroy_manager
    @user = @site.user
    if @user
      @site.update_attribute :user_id, nil
      log_activity @site, "Manager #{@user.email} removed from site '#{@site.name}'"
      flash[:notice] = 'Site manager was removed'
    end
    redirect_to site_path(@site)
  end

  def set_manager
    @user = User.find(params[:user_id])
    if @user.site.present? && @user.site != @site
      redirect_to edit_manager_path(@site), alert: 'The user is the manager of another site'
    else
      @site.user = @user
      if @site.save
        log_activity @site, "Manager #{@user.email} was set for site '#{@site.name}'"
        redirect_to site_path(@site), notice: 'Site manager set'
      else
        redirect_to site_path(@site), alert: 'Error setting site manager'
      end
    end
  end

  def patients
    respond_to do |format|
      format.html {
        redirect_to site_path(@site)
      }
      format.csv {
        patients = @site.patients.includes(:mentor, :current_card).order("mentors.name")
        exporter = Site::PatientsCsvExporter.new patients
        render_csv exporter.export, "#{@site.name}-patients.csv"
      }
    end
  end

  def providers
    respond_to do |format|
      format.html {
        redirect_to site_path(@site)
      }
      format.csv {
        providers = @site.providers.includes(:clinic).order("clinics.name")
        exporter = Site::ProvidersCsvExporter.new providers
        render_csv exporter.export, "#{@site.name}-providers.csv"
      }
    end
  end

  def search
    authorize Site

    query = params[:q].gsub('-', '')

    if Patient.valid_agep_id?(query) and (patient = Patient.find_by_agep_id(query))
      redirect_to patient_in_mentor_path(patient)
    elsif Card.valid_serial_number?(query) and (card = Card.find_by_serial_number(query))
      redirect_to card
    else
      redirect_to :back, alert: 'Invalid AGEP ID or Card Serial Number'
    end
  end

  private

  def load_site
    @site = Site.find(params[:id])
    authorize @site
  end

  def add_breadcrumbs
    @show_breadcrumb = true
    add_breadcrumb 'Sites', sites_path
    if @site
      add_breadcrumb @site.name, @site
    end
  end

  def site_params
    params.require(:site).permit(:name, :training)
  end

  def user_manager_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
