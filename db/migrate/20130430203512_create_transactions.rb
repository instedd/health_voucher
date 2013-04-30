class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :provider
      t.references :voucher
      t.references :service
      t.references :authorization
      t.references :statement
      t.string :status
      t.text :comment

      t.timestamps
    end
    add_index :transactions, :provider_id
    add_index :transactions, :voucher_id
    add_index :transactions, :service_id
    add_index :transactions, :authorization_id
    add_index :transactions, :statement_id
  end
end
