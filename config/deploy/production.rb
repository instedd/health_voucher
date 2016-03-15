set :deploy_user, 'ubuntu'
set :passenger_restart_with_touch, true
set :rvm_ruby_version, :default
server 'instedd1.instedd.org', user: fetch(:deploy_user), roles: %w{app db web}
