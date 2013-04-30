class CreateStatements < ActiveRecord::Migration
  def change
    create_table :statements do |t|
      t.references :clinic
      t.date :until
      t.string :status
      t.decimal :total

      t.timestamps
    end
    add_index :statements, :clinic_id
  end
end
