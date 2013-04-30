class CreateBatches < ActiveRecord::Migration
  def change
    create_table :batches do |t|
      t.string :name
      t.string :intial_serial_number
      t.integer :quantity

      t.timestamps
    end
  end
end
