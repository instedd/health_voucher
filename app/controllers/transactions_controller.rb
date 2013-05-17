class TransactionsController < ApplicationController
  before_filter :authenticate_admin!

  def index
    @transactions = Transaction.for_listing.order('id DESC').page params[:page]
  end

  def update_status
    @txn = Transaction.find(params[:id])
    @txn.update_status! params[:status], params[:comments]
  end
end
