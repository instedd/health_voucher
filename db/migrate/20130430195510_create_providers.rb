class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.string :name
      t.references :clinic
      t.string :code
      t.boolean :enabled

      t.timestamps
    end
    add_index :providers, :clinic_id
  end
end
