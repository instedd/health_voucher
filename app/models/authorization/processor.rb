class Authorization::Processor
  attr_reader :error, :error_options
  attr_reader :services

  def initialize(provider, patient, card, message = nil)
    @provider = provider
    @patient = patient
    @card = card
    @services = []
    @message = message
  end

  def error_message
    I18n.t "errors.#{@error}", (@error_options || {}) if @error
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

  def confirmed_or_pending_authorizations_for(clinic)
    todays_authorizations.select do |auth|
      auth.provider.clinic == clinic || auth.transaction.present?
    end
  end

  def max_daily_authorizations
    EVoucher::Application.config.max_daily_authorizations
  end

  def add_services(services)
    clinic = @provider.clinic
    pending_authorizations = current_pending_authorizations_for(clinic)
    available_vouchers = count_available_vouchers(clinic)
    auth_count = confirmed_or_pending_authorizations_for(clinic).count

    services.each do |service|
      # skip duplicate services
      next if @services.include?(service)
      
      # skip services already authenticated
      if pending_authorizations.find { |auth| auth.service == service }
        # but add them for the success message
        @services << service
        next
      end

      # check service availability
      if !clinic.provides_service?(service)
        set_error :service_not_provided, service: service

      # and voucher availability
      elsif available_vouchers[service.service_type] <= 0
        case service.service_type.to_sym
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
    unless validate and @services.any?
      raise RuntimeError, "Authorization::Processor.authorize called on invalid authorization"
    end

    Authorization.transaction do
      clinic = @provider.clinic

      # destroy other clinic's pending authorizations
      other_pending_authorizations = @card.authorizations.pending.today
      other_pending_authorizations.each do |auth|
        if auth.provider.clinic != clinic
          auth.destroy
        end
      end

      # create authorizations for each service
      pending_authorizations = current_pending_authorizations_for(clinic)
      @services.each do |service|
        unless pending_authorizations.find { |auth| auth.service == service }
          @card.authorizations.create! provider: @provider, service: service, message: @message
        end
      end

      # set card's validity if was nil
      @card.update_attribute :validity, Date.today if @card.validity.nil?
    end

    options = {
      serial_number: @card.full_serial_number, 
      services_short_desc: @services.map(&:short_description).join(', ')
    }

    if training?
      message_code = "training.authorization_success"
    else
      message_code = "authorization_success"
    end

    I18n.t message_code, options
  end

  def training?
    @card.site.try(:training?) || @provider.site.try(:training?)
  end

  private

  def set_error(code, options = {})
    if @error.nil?
      service = options.delete(:service)
      options = {
        serial_number: @card.full_serial_number,
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

