class AddIndicesToCards < ActiveRecord::Migration
  def change
    add_column :cards, :batch_id, :integer

    add_index :cards, :pacient_id
    add_index :cards, :site_id
    add_index :cards, :batch_id
  end
end
