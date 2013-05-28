class StatementsController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :load_statement, :only => [:show, :destroy, :toggle_status, :export]
  before_filter :add_breadcrumbs

  def index
    since_date = Date.parse_human_param(params[:since]).beginning_of_day rescue nil
    until_date = Date.parse_human_param(params[:until]).end_of_day rescue nil

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

    list = list.where('clinics.site_id = ?', params[:site_id]) if params[:site_id].present?
    list = list.where('statements.clinic_id = ?', params[:clinic_id]) if params[:clinic_id].present?
    list = list.where('statements.status = ?', params[:status]) if params[:status].present?
    list = list.where('statements.created_at >= ?', since_date) if since_date.present?
    list = list.where('statements.created_at <= ?', until_date) if until_date.present?

    direction = if %w(asc desc).include?(params[:direction]) 
                  params[:direction] 
                else 
                  'desc'
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
           when 'until'
             'statements.until'
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

  def export
    @exporter = Statement::CsvExporter.new(@stmt)
    response.headers['Content-type'] = 'text/csv'
    response.headers['Content-disposition'] = "attachment; filename=\"#{@stmt.clinic.name}-#{@stmt.created_at.to_s(:file_date)}.csv\""

    render text: @exporter.export
  end

  def generate
    add_breadcrumb 'Generate', generate_statements_path
    @form = Statement::GenerateForm.new
  end

  def do_generate
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

  private

  def add_breadcrumbs
    @show_breadcrumb = true
    add_breadcrumb 'Statements', statements_path
  end

  def load_statement
    @stmt = Statement.find(params[:id])
  end
end
