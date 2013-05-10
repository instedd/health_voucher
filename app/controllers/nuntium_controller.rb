class NuntiumController < BasicAuthController
  def receive
    render text: 'OK', :content_type => 'text/plain'
  end
end
