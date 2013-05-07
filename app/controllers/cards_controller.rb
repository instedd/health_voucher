class CardsController < ApplicationController
  before_filter :load_site
  before_filter :add_breadcrumbs

  def index
    @batches = Batch.have_unassigned_cards.sort_by(&:name)
  end

  def batch_assign
    batch = Batch.find(params[:batch_id])
    qty = params[:quantity].to_i
    result = Batch::CardAllocator.new(batch).assign_to_site(
      @site, params[:first_serial_number], qty)
    if result
      flash[:notice] = "#{result.count} cards assigned to Site's stock"
    else
      flash[:alert] = "Could not assign cards"
    end
    redirect_to site_cards_path(@site)
  end

  def assign
    card = Card.find_by_serial_number(params[:serial_number])
    if card
      if Batch::CardAllocator.new(card.batch).assign_to_site(
        @site, params[:serial_number])
        flash[:notice] = "Card assigned to Site's stock"
      else
        flash[:alert] = "Could not assign card"
      end
    else
      flash[:alert] = "Card does not exist"
    end 
    redirect_to site_cards_path(@site)
  end

  def return
    cards = Card::Returner.new.return_cards(params[:return_ids])
    redirect_to site_cards_path(@site), notice: "#{cards.size} cards returned"
  end

  private

  def load_site
    @site = Site.find(params[:site_id])
  end

  def add_breadcrumbs
    @show_breadcrumb = true
    add_breadcrumb 'Sites', sites_path
    add_breadcrumb @site.name, sites_path
    add_breadcrumb 'Assign cards', site_cards_path
  end
end
