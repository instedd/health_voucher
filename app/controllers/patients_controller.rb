class PatientsController < ApplicationController
  def assign_card
    @patient = Patient.find(params[:id])
  end

  def do_assign_card
    @patient = Patient.find(params[:id])
    # FIXME
    redirect_to manage_site_mentor(@patient.mentor.site, @patient.mentor)
  end
end
