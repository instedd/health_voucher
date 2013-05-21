class TransactionsController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :add_breadcrumbs

  def index
    @transactions = Transaction.for_listing.order('id DESC').page params[:page]
  end

  def update_status
    @txn = Transaction.find(params[:id])
    @txn.update_status params[:status], params[:comment]
  end

  private

  def add_breadcrumbs
    @show_breadcrumb = true
    add_breadcrumb 'Transactions', transactions_path
  end
end
