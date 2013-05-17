class TransactionsController < ApplicationController
  before_filter :authenticate_admin!

  def index
    @transactions = Transaction.for_listing.page params[:page]
  end
end
