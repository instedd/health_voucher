class StatementsController < ApplicationController
  before_filter :load_statement, :only => [:show, :destroy, :toggle_status]
  before_filter :add_breadcrumbs

  def index
    authorize Statement

    since_date = Date.parse_human_param(params[:since]).beginning_of_day rescue nil
    until_date = Date.parse_human_param(params[:until]).end_of_day rescue nil

    txn_from_date = Date.parse_human_param(params[:txn_from]).beginning_of_day rescue nil
    txn_to_date = Date.parse_human_param(params[:txn_to]).end_of_day rescue nil

    list = Statement.for_listing

    if params[:stmt_id].present?
      if params[:stmt_id].match /\d*-\d*/
        lower, upper = params[:stmt_id].split('-')
        list = list.where('statements.id >= ?', lower) if lower.present?
        list = list.where('statements.id <= ?', upper) if upper.present?
      else
        ids = params[:stmt_id].split(',')
        list = list.where('statements.id' => ids)
      end
    end

    if params[:site_id].present?
      clinic_ids = Clinic.where('site_id' => params[:site_id]).pluck(:id)
      list = list.where('statements.clinic_id' => clinic_ids)
    end
    list = list.where('statements.clinic_id' => params[:clinic_id]) if params[:clinic_id].present?
    list = list.where('statements.status' => params[:status]) if params[:status].present?
    list = list.where('statements.created_at >= ?', since_date) if since_date.present?
    list = list.where('statements.created_at <= ?', until_date) if until_date.present?

    if txn_from_date.present? or txn_to_date.present?
      list = list.where('transactions.created_at >= ?', txn_from_date) if txn_from_date.present?
      list = list.where('transactions.created_at <= ?', txn_to_date) if txn_to_date.present?
    end

    direction = if %w(asc desc).include?(params[:direction]) 
                  params[:direction] 
                else 
                  'desc'
                end
    if %w(site clinic).include?(params[:sort])
      # add joins to allow order by without losing the selected fields
      list = list.joins('INNER JOIN clinics ON statements.clinic_id = clinics.id').
        joins('INNER JOIN sites ON clinics.site_id = sites.id')
    end
    sort = case params[:sort]
           when 'id'
             'statements.id'
           when 'date'
             'statements.created_at'
           when 'site'
             'sites.name'
           when 'clinic'
             'clinics.name'
           when 'txn_from'
             'txn_from'
           when 'txn_to'
             'txn_to'
           when 'status'
             'statements.status'
           else
             'statements.created_at'
           end
    if sort.present?
      list = list.reorder("#{sort} #{direction}")
    end
    @statements = list.page params[:page]
  end

  def show
    add_breadcrumb "ID ##{@stmt.id}", @stmt
    respond_to do |format|
      format.html
      format.csv {
        @exporter = Statement::CsvExporter.new(@stmt)
        filename = "#{@stmt.clinic.name}-#{@stmt.created_at.to_s(:file_date)}.csv"
        render_csv @exporter.export, filename
      }
    end
  end

  def destroy
    txns = @stmt.transactions.map(&:id)

    @stmt.destroy

    log_activity @stmt, "Statement destroyed (Date #{@stmt.created_at.to_s(:transaction)}, Site '#{@stmt.site.name}', Clinic '#{@stmt.clinic.name}', Until #{@stmt.until.to_time_in_current_zone.to_s(:date)}, Transactions #{txns.join(',')})"

    redirect_to statements_path, :notice => 'Statement deleted'
  end

  def toggle_status
    @stmt.toggle_status!

    log_activity @stmt, "Status changed to '#{@stmt.status}'"

    if @stmt.paid?
      flash[:notice] = 'Statement marked as paid'
    else
      flash[:notice] = 'Statement marked as unpaid'
    end
    redirect_to @stmt
  end

  def generate
    authorize Statement

    add_breadcrumb 'Generate', generate_statements_path
    @form = Statement::GenerateForm.new
  end

  def do_generate
    authorize Statement, :generate?

    @form = Statement::GenerateForm.new(params[:statement_generate_form])
    if @form.valid?
      stmts = @form.generate

      stmts.each do |stmt|
        log_activity stmt, "Statement generated for site '#{stmt.site.name}', clinic '#{stmt.clinic.name}'"
      end

      redirect_to statements_path, notice: "#{stmts.count} statements generated"
    else
      add_breadcrumb 'Generate', generate_statements_path
      render 'generate'
    end
  end

  def export
    authorize Statement, :export?

    ids = params[:stmt_ids].split(',')
    @statements = Statement.where(:id => ids).includes(:clinic)
    clinic_ids = @statements.map(&:clinic_id).uniq
    @clinics = Clinic.where(:id => clinic_ids).includes(:clinic_services => :service)
    @visits = Hash[@clinics.map do |clinic|
      services = Hash[clinic.clinic_services.map do |cs|
        [cs.service_id, 0]
      end]
      [clinic.id, services]
    end]
    @statements.includes(:transactions => :authorization).each do |stmt|
      stmt.transactions.each do |txn|
        @visits[stmt.clinic_id][txn.service_id] += 1
      end
    end
    render xlsx: 'export', filename: 'statements.xlsx', disposition: 'attachment'
  end

  private

  def add_breadcrumbs
    @show_breadcrumb = true
    add_breadcrumb 'Statements', statements_path
  end

  def load_statement
    @stmt = Statement.find(params[:id])
    authorize @stmt
  end
end
