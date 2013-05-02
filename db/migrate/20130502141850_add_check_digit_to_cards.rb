class AddCheckDigitToCards < ActiveRecord::Migration
  def change
    add_column :cards, :check_digit, :string
  end
end
