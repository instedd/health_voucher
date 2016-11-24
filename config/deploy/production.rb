set :branch, :master
set :deploy_user, 'ec2-user'
server 'evouchers.instedd.org', user: fetch(:deploy_user), roles: %w{app db web}
