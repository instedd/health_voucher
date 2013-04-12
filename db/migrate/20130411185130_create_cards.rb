class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :serial_number

      t.timestamps
    end
  end
end
