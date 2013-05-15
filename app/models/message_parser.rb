class MessageParser
  attr_reader :error, :error_options
  attr_accessor :tokens

  attr_reader :provider_code, :agep_id, :serial_number, :service_codes
  attr_reader :service_code, :voucher_code

  attr_reader :provider, :patient, :card, :voucher, :services, :service

  def initialize(body)
    @body = body
  end

  def parse
    @services = []
    @service_codes = []
    @tokens = split_tokens(@body)

    unless validate_tokens(@tokens) && @tokens.length > 0
      set_error :invalid_message
      return nil
    end

    if @tokens.length == 2 &&
       @tokens[0].length == Service::SERVICE_CODE_LENGTH
      parse_confirmation
    else
      parse_authorization
    end
  end

  def error_message
    I18n.t "errors.#{@error}", (@error_options || {}) if @error
  end
  
  private

  def parse_confirmation
    self.service_code = @tokens[0]
    self.voucher_code = @tokens[1]

    if @error.nil?
      :confirmation
    else
      nil
    end
  end

  def parse_authorization
    if @tokens.length == 1
      set_error :missing_separators
    else
      self.provider_code = @tokens[0]
      if @tokens.length == 2
        set_error :missing_2nd_sep
      else
        self.agep_id = @tokens[1]
        if @tokens.length == 3
          set_error :missing_3rd_sep
        else
          self.serial_number = @tokens[2]
          (3..(@tokens.length - 1)).each do |i|
            add_service @tokens[i]
          end
        end
      end
    end

    if @error.nil?
      :authorization
    else
      nil
    end
  end

  def provider_code=(code)
    if code.length == Provider::PROVIDER_CODE_LENGTH
      @provider = Provider.find_by_code(code)
      if @provider.nil? || @provider.disabled?
        set_error :provider_disabled, provider_code: code
      else
        @provider_code = code
      end
    else
      set_error :provider_invalid, provider_code: code
    end
  end

  def agep_id=(agep_id)
    if Patient.valid_agep_id?(agep_id)
      @patient = Patient.find_by_agep_id(agep_id)
      if @patient.nil?
        set_error :agep_id_not_exists, agep_id: agep_id
      else
        @agep_id = agep_id
      end
    else
      set_error :agep_id_invalid, agep_id: agep_id
    end
  end

  def serial_number=(sn)
    if sn.length == Card::SERIAL_NUMBER_LENGTH + 1
      if Card.valid_serial_number?(sn)
        @card = Card.find_by_serial_number(sn)
        if @card.nil?
          set_error :serial_number_not_exists, serial_number: sn
        else
          @serial_number = sn
        end
      else
        set_error :serial_number_crc_invalid, serial_number: sn
      end
    else
      set_error :serial_number_invalid, serial_number: sn
    end
  end

  def add_service(code)
    if code.length == Service::SERVICE_CODE_LENGTH
      service = Service.find_by_code(code)
      if service.nil?
        set_error :service_code_invalid, service_code: code
      else
        @services << service
        @service_codes << code
      end
    else
      set_error :service_code_invalid, service_code: code
    end
  end

  def service_code=(code)
    if code.length == Service::SERVICE_CODE_LENGTH
      @service = Service.find_by_code(code)
      if @service.nil?
        set_error :service_code_invalid, service_code: code
      else
        @service_code = code
      end
    else
      set_error :service_code_invalid, service_code: code
    end
  end

  def voucher_code=(code)
    if code.length == Voucher::VOUCHER_CODE_LENGTH
      if Voucher.valid_voucher_code?(code)
        @voucher = Voucher.find_by_code(code)
        if @voucher.nil?
          set_error :voucher_code_not_exists, voucher_code: code
        else
          @voucher_code = code
        end
      else
        set_error :voucher_code_crc_invalid, voucher_code: code
      end
    else
      set_error :voucher_code_invalid, voucher_code: code
    end
  end

  def set_error(code, options = {})
    if @error.nil?
      @error = code
      @error_options = options
    end
  end

  def split_tokens(body)
    body.strip.split(/\s*[*+]+\s*/)
  end

  def validate_tokens(tokens)
    tokens.all? do |token|
      token =~ /\A[0-9]+\z/
    end
  end
end

