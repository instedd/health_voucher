class BasicAuthController < ApplicationController
  before_filter :authenticate
  
  private
  
  def authenticate
    config = EVoucher::Application.config
    authenticate_or_request_with_http_basic do |username, password|
      username == config.basic_auth_name && password == config.basic_auth_pwd
    end
  end
end
