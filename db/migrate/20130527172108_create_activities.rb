class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :user
      t.string :object_class
      t.integer :object_id
      t.text :description

      t.timestamps
    end
    add_index :activities, :user_id
    add_index :activities, :object_class
    add_index :activities, :object_id
    add_index :activities, :created_at
  end
end
