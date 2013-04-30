class CreatePacients < ActiveRecord::Migration
  def change
    create_table :pacients do |t|
      t.string :agep_id
      t.references :mentor

      t.timestamps
    end
    add_index :pacients, :mentor_id
  end
end
