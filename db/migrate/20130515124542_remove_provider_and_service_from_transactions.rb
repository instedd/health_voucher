class RemoveProviderAndServiceFromTransactions < ActiveRecord::Migration
  def up
    remove_column :transactions, :provider_id
    remove_column :transactions, :service_id
  end

  def down
    add_column :transactions, :service_id, :integer
    add_column :transactions, :provider_id, :integer
    add_index :transactions, :service_id
    add_index :transactions, :provider_id
  end
end
