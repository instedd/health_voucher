class CreateMentors < ActiveRecord::Migration
  def change
    create_table :mentors do |t|
      t.string :name
      t.references :site

      t.timestamps
    end
    add_index :mentors, :site_id
  end
end
