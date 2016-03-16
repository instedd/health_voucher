class CardsController < ApplicationController
  before_filter :load_card

  def show
  end

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

  def set_expiration
    if @card.patient.nil?
      redirect_to root_path
      return
    end

    @card.expiration = params[:expiration]
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
    authorize @card
  end
end
