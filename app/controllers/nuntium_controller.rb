class NuntiumController < BasicAuthController
  skip_before_filter :verify_authenticity_token

  def receive
    begin
      parser = MessageParser.new(params[:body])
      
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
        result = "confirmation"
      else
        result = parser.error_message
      end

    rescue Exception => e
      Rails.logger.error "exception while processing Nuntium message: #{e}"
      Rails.logger.error e.backtrace.join("\n")
      result = "Internal error. Please retry in a few minutes."
    end

    render text: "#{result}", :content_type => 'text/plain'
  end
end
