class StatementsController < ApplicationController
  before_filter :authenticate_admin!

  def index
    @statements = Statement.for_listing.order('id DESC').page params[:page]
  end

  def show
    @stmt = Statement.find(params[:id])
  end
end
