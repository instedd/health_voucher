class ProvidersController < ApplicationController
  def create
    @provider = Provider.new(provider_params)
    authorize @provider
    if @provider.save
      flash[:notice] = "The provider was added"
    end
    respond_to do |format|
      format.js
      format.html {
        @clinic = @provider.clinic
        redirect_to site_clinic_path(@clinic.site, @clinic)
      }
    end
  end

  def destroy
    @provider = Provider.find(params[:id])
    authorize @provider
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
    authorize @provider
    @provider.update_attribute :enabled, params[:enabled].present?
    head :ok
  end

  private

  def provider_params
    params.require(:provider).permit(:clinic_id, :code, :name)
  end
end
