class CardsController < ApplicationController
  before_filter :authenticate_user!

  def start_validity
    @card = Card.find(params[:id])
    if @card.patient
      @card.validity = params[:validity]
      if @card.save
        flash[:notice] = "Card validity date set"
      else
        flash[:alert] = "Card validity date not set: #{@card.errors.full_messages.join(', ')}"
      end
      mentor = @card.patient.mentor
      site = mentor.site
      redirect_to manage_site_mentor_path(site, mentor)
    else
      redirect_to manage_sites_path
    end
  end
end
