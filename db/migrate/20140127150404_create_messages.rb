class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :from
      t.string :body
      t.string :type
      t.string :status
      t.string :response

      t.timestamps
    end
  end
end
