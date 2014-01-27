class AddMessageIdToAuthorizations < ActiveRecord::Migration
  def change
    add_column :authorizations, :message_id, :integer
    add_index :authorizations, :message_id
  end
end
