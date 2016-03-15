source 'https://rubygems.org'

gem 'rails', '~> 3.2.22'
gem 'thin'

gem 'mysql2', '~> 0.3.17'
gem 'enumerize'
gem 'devise', '~> 3.5.6'
gem 'pundit', '~> 1.0.1'

gem 'delayed_job_active_record', '~> 4.1.0'
gem 'foreman', '~> 0.78', :require => false
gem 'newrelic_rpm'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'haml', '~> 4.0.7'
gem 'jquery-rails', '~> 2.0.2'
gem 'instedd-rails'
gem 'kaminari'
gem 'axlsx_rails'

group :development, :test do
  gem 'rspec-rails', '~> 3.4'
  gem 'machinist'
  gem 'timecop'
  gem 'mocha', :require => false
end

group :development do
  gem 'pry'
  gem 'capistrano',           '~> 3.4', :require => false
  gem 'capistrano-rails',     '~> 1.1', :require => false
  gem 'capistrano-bundler',   '~> 1.1', :require => false
  gem 'capistrano-rvm',       '~> 0.1', :require => false
  gem 'capistrano-passenger',           :require => false
end
