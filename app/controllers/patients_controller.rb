class PatientsController < ApplicationController
  def assign_card
    @patient = Patient.find(params[:id])
    @mentor = @patient.mentor
    @site = @mentor.site
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
end
