class RenameMessageTypeColumn < ActiveRecord::Migration
  def change
    rename_column :messages, :type, :message_type
  end
end
