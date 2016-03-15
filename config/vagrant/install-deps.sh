#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

apt-get update

# Install basic services
apt-get -q -y install mysql-server apache2 git

# Install requirements for building Ruby and gems
# libmysqlclient-dev for mysql2
# libgmp-dev for json
# nodejs for coffee-rails
apt-get -q -y install build-essential libmysqlclient-dev libgmp-dev nodejs
