ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'

require 'rspec/rails'
require 'mocha/setup'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

# Checks for pending migration and applies them before tests are run.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!
  config.infer_base_class_for_anonymous_controllers = false

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  # Set time zone for testing
  config.before(:each) do
    Time.zone = 'Auckland'
  end

  # Timecop reset after each test
  config.after(:each) do
    Timecop.return
  end

  # Devise Helpers
  config.include Devise::TestHelpers, :type => :controller
end
