# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'health_voucher'
set :repo_url, 'git@github.com:instedd/health_voucher.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, :master

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/u/apps/#{fetch(:application)}"

set :scm, :git
set :format, :pretty
set :log_level, :info
set :pty, true

set :linked_files, fetch(:linked_files, []).push('config/settings.yml', 'config/database.yml', 'config/newrelic.yml', 'config/secrets.yml')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets')

# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

# Configuration for capistrano/rails
set :rails_env, :production

# Name for the exported service
set :service_name, fetch(:application)

namespace :service do
  task :export do
    on roles(:app) do
      opts = {
        app: fetch(:service_name),
        log: File.join(shared_path, 'log'),
        user: fetch(:deploy_user),
        concurrency: "delayed=1,puma=1"
      }

      execute(:mkdir, "-p", opts[:log])

      within release_path do
        execute :sudo, '/usr/local/bin/bundle', "exec", "foreman", 'export',
                'upstart', '/etc/init', '-t', "etc/upstart",
                opts.map { |opt, value| "--#{opt}=\"#{value}\"" }.join(' ')
      end
    end
  end

  # Capture the environment variables for Foreman
  before :export, :set_env do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, "env | grep '^\\(PATH\\|GEM_PATH\\|GEM_HOME\\|RAILS_ENV\\|PUMA_OPTS\\)'", "> .env"
        end
      end
    end
  end

  task :safe_restart do
    on roles(:app) do
      execute "sudo stop #{fetch(:service_name)} ; sudo start #{fetch(:service_name)}"
    end
  end
end

namespace :deploy do
  after :updated, "service:export"         # Export foreman scripts
  after :restart, "service:safe_restart"   # Restart background services

  before :set_current_revision, :delete_revision do
    on roles(:app) do
      within release_path do
        execute :rm, 'REVISION'
      end
    end
  end
end
