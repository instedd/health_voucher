class BatchesController < ApplicationController
  before_filter :authenticate_admin!

  def index
    @batches = Batch.order('created_at ASC').page params[:page]
  end
end
