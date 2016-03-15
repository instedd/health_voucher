#!/usr/bin/env bash

# Ensure vagrant user can use RVM
adduser vagrant rvm

# Create directories for Capistrano
mkdir -p /u/apps /u/apps/health_voucher/shared/config
chown -R vagrant:vagrant /u/apps

# Create empty database
mysql -uroot -e "CREATE DATABASE evouchers_production"

# Enable Apache2 site configuration
cp /home/vagrant/health_voucher.conf /etc/apache2/sites-available
a2ensite health_voucher
a2dissite 000-default
service apache2 reload
