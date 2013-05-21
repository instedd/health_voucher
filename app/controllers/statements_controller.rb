class StatementsController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :add_breadcrumbs

  def index
    @statements = Statement.for_listing.order('id DESC').page params[:page]
  end

  def show
    @stmt = Statement.find(params[:id])
    add_breadcrumb @stmt.id, @stmt
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
end
