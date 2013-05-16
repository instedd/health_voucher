class PatientsController < ApplicationController
  before_filter :load_patient

  def assign_card
    @card = @site.unassigned_cards.find_by_serial_number(params[:serial_number])
    if @card
      @patient.current_card = @card
      @patient.save
      flash[:notice] = "Card assigned"
    else
      flash[:alert] = "Card not found or already assigned"
    end
    redirect_to manage_site_mentor_path(@site, @mentor)
  end
  
  def lost_card
    @card = @patient.current_card
    if @card
      @patient.report_lost_card!
      flash[:notice] = "Card was reported lost"
    end
    redirect_to manage_site_mentor_path(@site, @mentor)
  end

  private

  def load_patient
    @patient = Patient.find(params[:id])
    @mentor = @patient.mentor
    @site = @mentor.site
    unless current_user.admin? || @site.manager == current_user
      permission_denied
    end
  end
end
