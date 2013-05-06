class CardsController < ApplicationController
  before_filter :load_site

  def index
    @batches = Batch.have_unassigned_cards.sort_by(&:name)
  end

  def create
    if params[:batch_id]
      result = assign_from_batch
    elsif params[:serial_number]
      result = assign_individual
    end
    if result
      flash[:notice] = "#{result.count} cards assigned to Site's stock"
    else
      flash[:alert] = "Could not assign cards"
    end
    redirect_to site_cards_path(@site)
  end

  def return
    cards = Card::Returner.new.return_cards(params[:return_ids])
    redirect_to site_cards_path(@site), notice: "#{cards.size} cards returned"
  end

  private

  def assign_from_batch
    batch = Batch.find(params[:batch_id])
    qty = params[:quantity].to_i
    Batch::CardAllocator.new(batch).assign_to_site(
      @site, params[:first_serial_number], qty)
  end

  def assign_individual
    card = Card.find_by_serial_number(params[:serial_number])
    if card
      Batch::CardAllocator.new(card.batch).assign_to_site(
        @site, params[:serial_number])
    end 
  end

  def load_site
    @site = Site.find(params[:site_id])
  end
end
