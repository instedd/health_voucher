namespace :users do
  desc "Create a new admin user (password will be set to user part of email, duplicated if too short)"
  task :create, [:email] => :environment do |t, args|
    email = args[:email]
    password = email.split('@')[0]
    if password.length < 6
      password = password * 2
    end
    user = User.create! email: email, password: password
    user.update_attribute :admin, true
    puts "User created with id #{user.id}"
  end
end

