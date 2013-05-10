class NuntiumController < BasicAuthController
  skip_before_filter :verify_authenticity_token

  def receive
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
    
    render text: "#{result}\n", :content_type => 'text/plain'
  end
end
