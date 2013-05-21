EVoucher::Application.config.google_analytics = ''
EVoucher::Application.config.version_name = ''

InsteddRails.configure do |config|
  config.application_name = 'Health Voucher'
  config.google_analytics = ''
  config.version_name = File.read('REVISION') rescue 'Development'
end

