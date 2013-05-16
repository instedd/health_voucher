class CardsController < ApplicationController
  before_filter :authenticate_admin!

  def start_validity
    @card = Card.find(params[:id])
    if @card.patient
      # FIXME: parameterize date format
      @card.validity = Date.strptime(params[:validity], "%m/%d/%Y") rescue Date.today
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
