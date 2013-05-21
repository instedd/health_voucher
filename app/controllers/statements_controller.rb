class StatementsController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :load_statement, :only => [:show, :destroy, :toggle_status]
  before_filter :add_breadcrumbs

  def index
    @statements = Statement.for_listing.order('id DESC').page params[:page]
  end

  def show
    add_breadcrumb "ID ##{@stmt.id}", @stmt
  end

  def destroy
    @stmt.destroy
    redirect_to statements_path, :notice => 'Statement deleted'
  end

  def toggle_status
    @stmt.toggle_status!
    if @stmt.paid?
      flash[:notice] = 'Statement marked as paid'
    else
      flash[:notice] = 'Statement marked as unpaid'
    end
    redirect_to @stmt
  end

  def generate
    add_breadcrumb 'Generate', generate_statements_path
    @form = Statement::GenerateForm.new
  end

  def do_generate
    @form = Statement::GenerateForm.new(params[:statement_generate_form])
    if @form.valid?
      stmts = @form.generate
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
