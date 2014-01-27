class Message::Processor
  attr_reader :from, :body

  def initialize(body, from = nil)
    @body = body
    @from = from
  end

  def process
    parser = Message::Parser.new(@body)

    case parser.parse
    when :authorization
      processor = Authorization::Processor.new(parser.provider, 
                                               parser.patient, 
                                               parser.card)
      if processor.validate() && processor.add_services(parser.services)
        result = processor.authorize
      else
        result = processor.error_message
      end

    when :confirmation
      processor = Transaction::Processor.new(parser.service, parser.voucher)

      if processor.validate()
        result = processor.confirm
      else
        result = processor.error_message
      end

    else
      result = parser.error_message
    end

    result
  end
end

