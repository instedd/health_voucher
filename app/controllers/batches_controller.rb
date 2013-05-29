class BatchesController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :add_breadcrumbs

  def index
    @batches = Batch.order('created_at ASC').page params[:page]
  end

  def show
    respond_to do |format|
      format.html {
        redirect_to batches_path
      }
      format.csv {
        @batch = Batch.find(params[:id])
        @exporter = Batch::CsvExporter.new(@batch)
        render_csv @exporter.export, "#{@batch.name}.csv"
      }
    end
  end

  private

  def add_breadcrumbs
    @show_breadcrumb = true
    add_breadcrumb 'Batches', batches_path
  end
end
