class AddMessageIdToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :message_id, :integer
    add_index :transactions, :message_id
  end
end
