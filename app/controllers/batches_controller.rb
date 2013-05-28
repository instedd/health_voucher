class BatchesController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :add_breadcrumbs

  def index
    @batches = Batch.order('created_at ASC').page params[:page]
  end

  def export
    @batch = Batch.find(params[:id])
    @exporter = Batch::CsvExporter.new(@batch)
    response.headers['Content-type'] = 'text/csv'
    response.headers['Content-disposition'] = "attachment; filename=\"#{@batch.name}.csv\""

    render text: @exporter.export
  end

  private

  def add_breadcrumbs
    @show_breadcrumb = true
    add_breadcrumb 'Batches', batches_path
  end
end
