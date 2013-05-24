class MentorsController < SiteController
  before_filter :load_mentor
  before_filter :add_breadcrumbs

  def index
    @mentors = @site.mentors.order(:name)
    @mentor = Mentor.new
    @mentor.site = @site
  end

  def show
    @patients = @mentor.patients.order(:agep_id)
  end

  def create
    @mentor = @site.mentors.create(params[:mentor])
    if @mentor.valid?
      flash[:notice] = "Mentor added"
    end
    respond_to do |format|
      format.js
      format.html {
        redirect_to site_mentors_path(@site)
      }
    end
  end

  def destroy
    @mentor = @site.mentors.find(params[:id])
    @mentor.destroy
    if @mentor.destroyed?
      flash[:notice] = "Mentor was removed"
    else
      flash[:alert] = "Cannot remove mentor: #{@mentor.errors.full_messages.join}"
    end
    redirect_to site_mentors_path(@site)
  end

  def add_patients
    errors = []
    ids = params[:agep_ids].strip.split(/\s+/)
    ids.each do |agep_id|
      patient = @mentor.patients.create agep_id: agep_id
      unless patient.valid? 
        errors << "#{agep_id} #{patient.errors[:agep_id].first}"
      end
    end
    if errors.empty?
      flash[:notice] = "#{ids.size} AGEP IDs added"
    else
      flash[:alert] = "Failed to add these IDs: #{errors.join(', ')}"
    end
    redirect_to site_mentor_path(@site, @mentor)
  end

  def auto_assign
    initial = params[:initial_serial_number]
    if initial
      cards = @site.unassigned_cards.where("serial_number >= ?", initial)
      if cards.count == 0
        flash[:alert] = "No unassigned cards found from #{initial}"
      else
        assigned = 0
        @mentor.patients.without_card.zip(cards).each do |(patient, card)|
          patient.current_card = card
          if patient.save
            assigned += 1
          end
        end
        flash[:notice] = "#{assigned} cards assigned"
      end
    else
      flash[:alert] = "No initial Serial Number specified"
    end
    redirect_to site_mentor_path(@site, @mentor)
  end

  def move_patients
    @target_mentor = Mentor.find(params[:target_id])
    Patient.transaction do
      ids = params[:patient_ids].split(',')
      ids.each do |id|
        patient = Patient.find(id)
        patient.update_attribute :mentor, @target_mentor
      end
      flash[:notice] = "#{ids.count} AGEP IDs moved to #{@target_mentor.name}"
    end
    redirect_to site_mentor_path(@site, @mentor)
  end

  private

  def load_mentor
    @mentor = @site.mentors.find(params[:id]) unless params[:id].blank?
  end

  def add_breadcrumbs
    @show_breadcrumb = true
    if current_user.admin?
      add_breadcrumb 'Sites', sites_path
      add_breadcrumb @site.name, site_path(@site)
    end
    add_breadcrumb 'Mentors', site_mentors_path(@site)
    if @mentor
      add_breadcrumb @mentor.name, site_mentor_path(@site, @mentor)
    end
  end
end
