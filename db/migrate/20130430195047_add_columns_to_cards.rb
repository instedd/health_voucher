class AddColumnsToCards < ActiveRecord::Migration
  def change
    add_column :cards, :pacient_id, :integer
    add_column :cards, :site_id, :integer
    add_column :cards, :validity, :date
    add_column :cards, :status, :string
  end
end
