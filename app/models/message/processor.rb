class Message::Processor
  attr_reader :from, :body, :message

  def initialize(body, from = nil)
    @body = body
    @from = from
  end

  def process
    @message = Message.create! from: @from, body: @body    

    begin
      parser = Message::Parser.new(@body)

      case parser.parse
      when :authorization
        @message.message_type = :authorization
        processor = Authorization::Processor.new(parser.provider, 
                                                 parser.patient, 
                                                 parser.card)
        if processor.validate() && processor.add_services(parser.services)
          @message.succeed processor.authorize
        else
          @message.fail processor.error_message
        end

      when :confirmation
        @message.message_type = :confirmation
        processor = Transaction::Processor.new(parser.service, parser.voucher)

        if processor.validate()
          @message.succeed processor.confirm
        else
          @message.fail processor.error_message
        end

      else
        @message.set_error parser.error_message
      end

      @message.response

    rescue Exception => e
      @message.set_error "Exception: #{e}"
      raise
    ensure
      @message.save!
    end
  end
end

