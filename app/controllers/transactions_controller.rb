class TransactionsController < ApplicationController
  before_filter :add_breadcrumbs

  def index
    authorize Transaction

    since_date = Date.parse_human_param(params[:since]).beginning_of_day rescue nil
    until_date = Date.parse_human_param(params[:until]).end_of_day rescue nil

    list = Transaction.for_listing

    if params[:txn_id].present?
      if params[:txn_id].match /\d*-\d*/
        lower, upper = params[:txn_id].split('-')
        list = list.where('transactions.id >= ?', lower) if lower.present?
        list = list.where('transactions.id <= ?', upper) if upper.present?
      else
        ids = params[:txn_id].split(',')
        list = list.where('transactions.id' => ids)
      end
    end

    list = list.where('clinics.site_id' => params[:site_id]) if params[:site_id].present?
    list = list.where('clinics.id' => params[:clinic_id]) if params[:clinic_id].present?
    list = list.where('transactions.status' => params[:status]) if params[:status].present?
    list = list.where('transactions.created_at >= ?', since_date) if since_date.present?
    list = list.where('transactions.created_at <= ?', until_date) if until_date.present?

    direction = if %w(asc desc).include?(params[:direction]) 
                  params[:direction] 
                else 
                  'desc'
                end
    sort = case params[:sort]
           when 'id'
             'transactions.id'
           when 'date'
             'transactions.created_at'
           when 'clinic'
             'clinics.name'
           when 'provider'
             'providers.code'
           when 'service'
             'services.code'
           when 'agep_id'
             'patients.agep_id'
           when 'card'
             'cards.serial_number'
           when 'statement'
             'transactions.statement_id'
           when 'status'
             'transactions.status'
           else
             'transactions.id'
           end
    if sort.present?
      list = list.reorder("#{sort} #{direction}")
    end

    @transactions = list

    respond_to do |format|
      format.html {
        @transactions = @transactions.page params[:page]
      }
      format.csv {
        exporter = Transaction::ListCsvExporter.new(@transactions)
        render_csv exporter.export, "transactions.csv"
      }
    end
  end

  def update_status
    @txn = Transaction.find(params[:id])
    authorize @txn
    @txn.update_status params[:status], params[:comment]

    message = "Status changed to '#{@txn.status}'"
    if @txn.comment.blank?
      message << ", comment deleted"
    else
      message << ", comment set to '#{@txn.comment}'"
    end
    log_activity @txn, message

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

