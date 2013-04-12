class CreateVouchers < ActiveRecord::Migration
  def change
    create_table :vouchers do |t|
      t.string :code
      t.references :card
      t.string :panel

      t.timestamps
    end
    add_index :vouchers, :card_id
  end
end
