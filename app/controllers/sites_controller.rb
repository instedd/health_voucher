class SitesController < ApplicationController
  before_filter :load_site, :except => [:index, :new, :create]
  before_filter :add_breadcrumbs

  def index
    @sites = Site.all
  end

  def new
    add_breadcrumb 'New site', nil
    @site = Site.new
  end

  def create
    @site = Site.new(params[:site])
    if @site.save
      redirect_to sites_path, notice: 'Site was registered successfully'
    else
      add_breadcrumb 'New site', nil
      render :new
    end
  end

  def edit
    add_breadcrumb @site.name, nil
  end

  def update
    @site.update_attributes params[:site]
    if @site.save
      redirect_to sites_path, notice: 'Site was updated successfully'
    else
      add_breadcrumb @site.name, nil
      render :edit
    end
  end

  def assign_cards
    add_breadcrumb 'Assign cards', assign_cards_site_path
    @batches = Batch.have_unassigned_cards.sort_by(&:name)
  end

  def batch_assign_cards
    batch = Batch.find(params[:batch_id])
    qty = params[:quantity].to_i
    result = Batch::CardAllocator.new(batch).assign_to_site(
      @site, params[:first_serial_number], qty)
    if result
      flash[:notice] = "#{result.count} cards assigned to Site's stock"
    else
      flash[:alert] = "Could not assign cards"
    end
    redirect_to assign_cards_site_path(@site)
  end

  def assign_individual_card
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
    redirect_to assign_cards_site_path(@site)
  end

  def return_cards
    cards = Card::Returner.new.return_cards(params[:return_ids])
    redirect_to assign_cards_site_path(@site), notice: "#{cards.size} cards returned"
  end

  private

  def load_site
    @site = Site.find(params[:id])
  end

  def add_breadcrumbs
    @show_breadcrumb = true
    add_breadcrumb 'Sites', sites_path
    if @site
      add_breadcrumb @site.name, sites_path
    end
  end
end
