class CardsController < ApplicationController
  before_filter :load_card

  def start_validity
    if @card.patient.nil?
      redirect_to root_path 
      return
    end

    @card.validity = params[:validity]
    @card.save
    @patient = @card.patient
    respond_to do |format|
      format.js
      format.html {
        redirect_to site_mentor_path(@patient.site, @patient.mentor)
      }
    end
  end

  private
  
  def load_card
    @card = Card.find(params[:id])

    unless current_user.admin? || 
      (@card.patient.present? && @card.patient.site.manager == current_user)
      permission_denied
    end
  end
end
