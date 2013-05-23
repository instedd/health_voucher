class CardsController < ApplicationController
  before_filter :load_card

  def start_validity
    if @card.patient.nil?
      redirect_to root_path 
      return
    end

    # FIXME: parameterize date format
    @card.validity = Date.strptime(params[:validity], "%m/%d/%Y") rescue Date.today
    @card.save
    @patient = @card.patient
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
