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

  def new
    add_breadcrumb 'Generate', new_batch_path
    @batch = Batch.new initial_serial_number: Batch.next_serial_number, quantity: Batch::DEFAULT_QUANTITY
  end

  def create
    @batch = Batch.new(params[:batch])
    if @batch.save
      #Batch::Generator.new(@batch).generate! 
      redirect_to batches_path, notice: 'Batch created. Card generation started in the background.'
    else
      add_breadcrumb 'Generate', new_batch_path
      render :new
    end
  end

  private

  def add_breadcrumbs
    @show_breadcrumb = true
    add_breadcrumb 'Batches', batches_path
  end
end
