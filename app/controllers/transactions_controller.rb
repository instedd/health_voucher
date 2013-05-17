class TransactionsController < ApplicationController
  before_filter :authenticate_admin!

  def index
    @transactions = Transaction.for_listing.order('id DESC').page params[:page]
  end
end
