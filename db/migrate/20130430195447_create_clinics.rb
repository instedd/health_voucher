class CreateClinics < ActiveRecord::Migration
  def change
    create_table :clinics do |t|
      t.string :name
      t.references :site

      t.timestamps
    end
    add_index :clinics, :site_id
  end
end
