class ManagementController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_site
  before_filter :add_breadcrumbs

  def index
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
    redirect_to manage_site_mentor_path(@site, @mentor)
  end

  def assign
    initial = params[:initial_serial_number]
    if initial
      cards = @site.unassigned_cards.where("serial_number >= ?", initial)
      if cards.count == 0
        flash[:alert] = "No unassigned cards found from #{initial}"
      else
        assigned = 0
        @site.patients_without_cards.zip(cards).each do |(patient, card)|
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
    redirect_to manage_site_mentor_path(@site, @mentor)
  end

  def move
    @mentor = Mentor.find(params[:target_id])
    Patient.transaction do
      ids = params[:patient_ids].split(',')
      ids.each do |id|
        Patient.find(id).update_attribute :mentor, @mentor
      end
      flash[:notice] = "#{ids.count} AGEP IDs moved to #{@mentor.name}"
    end
    redirect_to manage_site_mentor_path(@site, @mentor)
  end

  private

  def load_site
    if params[:site_id]
      @site = Site.find(params[:site_id])
    else
      @site = Site.first
    end
    if @site
      if params[:mentor_id]
        @mentor = @site.mentors.find(params[:mentor_id])
      end
    end
  end

  def add_breadcrumbs
    @show_breadcrumb = true
    add_breadcrumb 'Site Management', manage_sites_path
    add_breadcrumb @site.name, manage_site_path(@site)
    if @mentor
      add_breadcrumb @mentor.name, manage_site_mentor_path(@site, @mentor)
    end
  end
end
