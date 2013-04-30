class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :service_type
      t.string :description
      t.string :short_description
      t.string :code

      t.timestamps
    end
  end
end
