source 'https://rubygems.org'

gem 'rails', '~> 4.0.13'
gem 'thin'

gem 'mysql2', '~> 0.3.17'
gem 'enumerize', '~> 0.11'    # 0.11 is the last version with Rails 3.2 support
gem 'devise', '~> 3.5.6'
gem 'pundit', '~> 1.0.1'      # > 1.0.1 breaks with Rails 3.2

gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'

gem 'delayed_job_active_record', '~> 4.1.0'
gem 'foreman', '~> 0.78', :require => false
gem 'newrelic_rpm'

gem 'haml', '~> 4.0.7'
gem 'jquery-rails', '~> 2.0.2'  # TODO: update to jQuery 1.12 (jquery-rails 4.1.1)
gem 'select2-rails', '~> 3.4.9'
gem 'instedd-rails', '~> 0.0.25'
gem 'kaminari', '~> 0.16.3'
gem 'axlsx_rails', '~> 0.3.0'   # 0.3.0 is the last version with Rails 3.2 support

group :development, :test do
  gem 'rspec-rails', '~> 3.4'
  gem 'machinist'
  gem 'timecop'
  gem 'mocha', :require => false
  gem 'quiet_assets'
end

group :development do
  gem 'pry'
  gem 'capistrano',           '~> 3.4', :require => false
  gem 'capistrano-rails',     '~> 1.1', :require => false
  gem 'capistrano-bundler',   '~> 1.1', :require => false
  gem 'capistrano-rvm',       '~> 0.1', :require => false
  gem 'capistrano-passenger',           :require => false
end
