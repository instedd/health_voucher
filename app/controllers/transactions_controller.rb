class TransactionsController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :add_breadcrumbs

  def index
    since_date = Date.parse_human_param(params[:since]).beginning_of_day rescue nil
    until_date = Date.parse_human_param(params[:until]).end_of_day rescue nil

    list = Transaction.for_listing
    list = list.where('clinics.site_id = ?', params[:site_id]) if params[:site_id].present?
    list = list.where('clinics.id = ?', params[:clinic_id]) if params[:clinic_id].present?
    list = list.where('transactions.status = ?', params[:status]) if params[:status].present?
    list = list.where('transactions.created_at >= ?', since_date) if since_date.present?
    list = list.where('transactions.created_at <= ?', until_date) if until_date.present?
    @transactions = list.order('transactions.id DESC').page params[:page]
  end

  def update_status
    @txn = Transaction.find(params[:id])
    @txn.update_status params[:status], params[:comment]
    respond_to do |format|
      format.js
      format.html {
        redirect_to transactions_path
      }
    end
  end

  private

  def add_breadcrumbs
    @show_breadcrumb = true
    add_breadcrumb 'Transactions', transactions_path
  end
end

