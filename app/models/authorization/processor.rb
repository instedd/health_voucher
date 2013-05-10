class Authorization::Processor
  attr_reader :error, :error_options

  def initialize(provider, patient, card)
    @provider = provider
    @patient = patient
    @card = card
  end

  def error_message
    I18n.t "errors.#{@error}", (@error_options || {})
  end

  def pre_validate
    if @card.patient != @patient
      set_error :card_agep_id_mismatch
    elsif @card.lost?
      set_error :card_stolen
    elsif @card.expired?
      set_error :card_expired
    end
    @error.nil?
  end

  def current_authorizations_for(clinic)
    @card.authorizations.today.reject do |auth|
      auth.provider.clinic != clinic
    end
  end

  def count_available_vouchers(clinic)
    result = { :primary => @card.unused_vouchers(:primary).count,
               :secondary => @card.unused_vouchers(:secondary).count }
    current_authorizations_for(clinic).each do |auth|
      result[auth.service.service_type] -= 1
    end
    result
  end

  def add_services(services)
    clinic = @provider.clinic
    available_vouchers = count_available_vouchers(clinic)
    auth_count = current_authorizations_for(clinic)

    services.each do |service|
      if !clinic.provides_service?(service)
        set_error :service_not_provided, service: service
      elsif available_vouchers[service.service_type] <= 0
        case service.service_type
        when :primary
          set_error :no_primary_vouchers, service: service
        when :secondary
          set_error :no_secondary_vouchers, service: service
        end
      end

      available_vouchers[service.service_type] -= 1
      auth_count += 1
    end

    if auth_count > max_daily_authorizations
      set_error :agep_id_authorization_limit, 
        services_desc: services.map(&:short_description).join(', ')
    end

    @error.nil?
  end

  def authorize
    # FIXME
    "OK"
  end

  private

  def set_error(code, options = {})
    if @error.nil?
      service = options.delete(:service)
      options = {
        serial_number: @card.serial_number,
        agep_id: @patient.agep_id,
        provider_code: @provider.code
      }.merge(options)
      if service
        options[:service_code] = service.code
        options[:service_short_desc] = service.short_description
      end

      @error = code
      @error_options = options
    end
  end
end

