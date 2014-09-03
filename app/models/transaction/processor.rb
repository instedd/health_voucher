class Transaction::Processor
  attr_reader :error, :error_options
  attr_reader :auth

  def initialize(service, voucher, message = nil)
    @service = service
    @voucher = voucher
    @auth = nil
    @message = message
  end

  def find_authorization
    @voucher.card.authorizations.today.pending.where(:service_id => @service.id).first
  end

  def validate
    @auth = find_authorization 
    if @auth.nil? or @auth.card.patient.nil?
      set_error :not_authorized
    elsif @voucher.used?
      set_error :voucher_already_used
    elsif @service.service_type != @voucher.service_type && !@voucher.any?
      case @service.service_type.to_sym
      when :primary
        set_error :voucher_not_primary
      when :secondary
        set_error :voucher_not_secondary
      end
    end
    @error.nil?
  end

  def confirm
    unless validate && !@auth.nil?
      raise RuntimeError, "Transaction::Processor.authorize called on invalid confirmation"
    end

    Transaction.transaction do
      @voucher.use!

      @txn = @auth.build_transaction
      @txn.voucher = @voucher
      @txn.message = @message
      @txn.amount = @auth.clinic_service.cost
      @txn.training = @auth.training?
      @txn.save!
    end

    options = {
      serial_number: @voucher.card.full_serial_number, 
      transaction_id: @txn.id, 
      service_short_desc: @service.short_description
    }

    if training?
      message_code = "training.confirmation_success"
    else
      message_code = "confirmation_success"
    end

    I18n.t message_code, options
  end

  def error_message
    I18n.t "errors.#{@error}", (@error_options || {}) if @error
  end

  private

  def training?
    @auth.training?
  end

  def set_error(code, options = {})
    if @error.nil?
      service = options.delete(:service)
      options = {
        service_short_desc: @service.short_description,
        voucher_code: @voucher.code,
        serial_number: @voucher.card.full_serial_number
      }.merge(options)

      @error = code
      @error_options = options
    end
  end

end

