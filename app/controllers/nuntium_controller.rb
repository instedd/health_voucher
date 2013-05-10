class NuntiumController < BasicAuthController
  skip_before_filter :verify_authenticity_token

  def receive
    parser = MessageParser.new(params[:body])
    
    if parser.parse
      result = "OK"
    else
      result = parser.error_message
    end
    
    render text: "#{result}\n", :content_type => 'text/plain'
  end
end
