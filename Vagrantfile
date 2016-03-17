# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  # config.vm.box_check_update = false

  config.vm.hostname = "health-voucher.local"
  config.vm.network "forwarded_port", guest: 80, host: 8080

  # config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.network "public_network"

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 2
  end

  config.vm.provision :shell, path: 'config/vagrant/install-deps.sh'
  config.vm.provision :shell, path: 'config/vagrant/install-rvm.sh', args: 'stable'
  config.vm.provision :shell, path: 'config/vagrant/install-ruby.sh', args: "#{`cat .ruby-version`} bundler"
  config.vm.provision :shell, path: 'config/vagrant/install-passenger.sh'

  # Copy Apache2 site (needed by install-post.sh)
  config.vm.provision :file, source: "config/vagrant/health_voucher.apache2.conf", destination: "~/health_voucher.conf"

  # Finish configuration
  config.vm.provision :shell, path: 'config/vagrant/install-post.sh'

  # Provision default configuration files
  %w(database.yml settings.yml newrelic.yml secrets.yml).each do |file|
    config.vm.provision :file, source: "config/vagrant/#{file}", destination: "/u/apps/health_voucher/shared/config/#{file}"
  end
end
