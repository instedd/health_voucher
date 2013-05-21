class CardsController < ApplicationController
  before_filter :load_card

  def start_validity
    if @card.patient.nil?
      redirect_to root_path 
      return
    end

    # FIXME: parameterize date format
    @card.validity = Date.strptime(params[:validity], "%m/%d/%Y") rescue Date.today
    if @card.save
      flash[:notice] = "Card validity date set"
    else
      flash[:alert] = "Card validity date not set: #{@card.errors.full_messages.join(', ')}"
    end

    mentor = @card.patient.mentor
    site = mentor.site
    redirect_to site_mentor_path(site, mentor)
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
