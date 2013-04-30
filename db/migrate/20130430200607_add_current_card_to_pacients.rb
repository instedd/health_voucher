class AddCurrentCardToPacients < ActiveRecord::Migration
  def change
    add_column :pacients, :current_card_id, :integer

    add_index :pacients, :current_card_id
  end
end
