class ProvidersController < ApplicationController
  before_filter :authenticate_admin!

  def create
    @provider = Provider.new(params[:provider], :as => :creator)
    if @provider.save
      flash[:notice] = "The provider was added"
    end
  end

  def destroy
    @provider = Provider.find(params[:id])
    @clinic = @provider.clinic
    @provider.destroy
    if @provider.destroyed?
      flash[:notice] = "The provider was removed"
    else
      flash[:alert] = "The provider could not be removed: #{@provider.errors.full_messages.join(', ')}"
    end
    redirect_to site_clinic_path(@clinic.site, @clinic)
  end

  def toggle
    @provider = Provider.find(params[:id])
    @provider.update_attribute :enabled, params[:enabled].present?
    head :ok
  end
end
