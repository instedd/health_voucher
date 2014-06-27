class AddRoleToUsers < ActiveRecord::Migration
  def up
    add_column :users, :role, :string, :default => "normal"
    connection.execute "UPDATE users SET role = IF(admin = 1, 'admin', 'site_manager')"
    remove_column :users, :admin
  end

  def down
    add_column :users, :admin, :boolean, :default => false
    connection.execute "UPDATE users SET admin = IF(role = 'admin', 1, 0)"
    remove_column :users, :role
  end
end
