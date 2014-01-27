class NuntiumController < BasicAuthController
  def receive
    begin
      processor = Message::Processor.new(params[:body], params[:from])
      result = processor.process

    rescue Exception => e
      Rails.logger.error "exception while processing Nuntium message: #{e}"
      Rails.logger.error e.backtrace.join("\n")
      result = "Internal error. Please retry in a few minutes."
    end

    render text: "#{result}", :content_type => 'text/plain'
  end
end
