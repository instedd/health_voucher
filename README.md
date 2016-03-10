# Health Voucher

This application handles the creation, release, management and clearing of
service vouchers. For an example of its application, see:
http://www.popcouncil.org/research/adolescent-girls-empowerment-program


## Development Setup

This is a standard Rails application. You need to have the required Ruby version
(from `.ruby-version`) installed. Use [rbenv](https://github.com/rbenv/rbenv) or
[RVM](https://rvm.io/) to manage your Ruby installations.

Perform the following steps to bootstrap the application for development:

1. Install the bundle:

    $ bundle install --path .bundle

2. Create the database for development and testing:

    $ bundle exec rake db:setup

3. Create a new `config/settings.yml` from the template file
   `config/settings.yml.template`.

To run the specificactions using RSpec, execute:

    $ bundle exec rspec

To start the development web server:

    $ bundle exec rails server


## Nuntium Configuration

The application has an entry point to receive and process service requests via
SMS or other types of messaging through [Nuntium](http://nuntium.instedd.org). The
configuration parameters `basic_auth_name` and `basic_auth_pwd` in
`config/settings.yml` are the credentials for Nuntium to authenticate with this
application.
