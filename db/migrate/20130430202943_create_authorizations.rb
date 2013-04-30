class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.references :card
      t.references :provider
      t.references :service

      t.timestamps
    end
    add_index :authorizations, :card_id
    add_index :authorizations, :provider_id
    add_index :authorizations, :service_id
  end
end
