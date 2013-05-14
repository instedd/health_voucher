class Authorization::Processor
  attr_reader :error, :error_options

  def initialize(provider, patient, card)
    @provider = provider
    @patient = patient
    @card = card
    @services = []
  end

  def error_message
    I18n.t "errors.#{@error}", (@error_options || {})
  end

  def validate
    if @provider.disabled?
      set_error :provider_disabled
    elsif @card.patient != @patient
      set_error :card_agep_id_mismatch
    elsif @card.lost?
      set_error :card_stolen
    elsif @card.expired?
      set_error :card_expired
    end
    @error.nil?
  end

  def todays_authorizations
    @card.authorizations.today
  end

  def current_pending_authorizations_for(clinic)
    todays_authorizations.pending.by_clinic(clinic)
  end

  def unused_vouchers_counts
    { :primary => @card.unused_vouchers(:primary).count,
      :secondary => @card.unused_vouchers(:secondary).count }.with_indifferent_access
  end

  def count_available_vouchers(clinic)
    result = unused_vouchers_counts
    current_pending_authorizations_for(clinic).each do |auth|
      result[auth.service.service_type] -= 1
    end
    result
  end

  def max_daily_authorizations
    EVoucher::Application.config.max_daily_authorizations
  end

  def add_services(services)
    clinic = @provider.clinic
    pending_authorizations = current_pending_authorizations_for(clinic)
    available_vouchers = count_available_vouchers(clinic)
    auth_count = todays_authorizations.count

    services.each do |service|
      # skip duplicate services
      next if @services.include?(service)
      
      # skip services already authenticated
      next if pending_authorizations.find { |auth| auth.service == service }

      # check service availability
      if !clinic.provides_service?(service)
        set_error :service_not_provided, service: service

      # and voucher availability
      elsif available_vouchers[service.service_type] <= 0
        case service.service_type
        when :primary
          set_error :no_primary_vouchers, service: service
        when :secondary
          set_error :no_secondary_vouchers, service: service
        end

      else
        available_vouchers[service.service_type] -= 1
        auth_count += 1
        @services << service
      end
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

