class ProvidersController < ApplicationController
  before_filter :authenticate_user!

  def create
    @clinic = Clinic.find(params[:clinic_id])
    @provider = Provider.new(params[:provider])
    @provider.clinic = @clinic
    if @provider.save
      flash[:notice] = "The provider was added"
    else
      flash[:alert] = "Error adding provider: #{@provider.errors.full_messages.join(', ')}"
    end
    redirect_to site_clinic_path(@clinic.site, @clinic)
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
end
