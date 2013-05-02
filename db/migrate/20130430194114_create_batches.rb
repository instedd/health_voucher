class CreateBatches < ActiveRecord::Migration
  def change
    create_table :batches do |t|
      t.string :name
      t.string :initial_serial_number
      t.integer :quantity

      t.timestamps
    end
  end
end
