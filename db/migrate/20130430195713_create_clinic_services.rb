class CreateClinicServices < ActiveRecord::Migration
  def change
    create_table :clinic_services do |t|
      t.references :clinic
      t.references :service
      t.boolean :enabled
      t.decimal :cost, :precision => 10, :scale => 2

      t.timestamps
    end
    add_index :clinic_services, :clinic_id
    add_index :clinic_services, :service_id
  end
end
