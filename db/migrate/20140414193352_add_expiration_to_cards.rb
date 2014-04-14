class AddExpirationToCards < ActiveRecord::Migration
  def up
    add_column :cards, :expiration, :date

    connection.execute "UPDATE cards SET expiration = validity + INTERVAL 1 YEAR WHERE validity IS NOT NULL"
  end

  def down
    remove_column :cards, :expiration
  end
end
