# Configure time zone as loaded from settings.yml
# (seems after loading application.rb ActiveSupport no longer cares about config.time_zone)

Time.zone = EVoucher::Application.config.time_zone

