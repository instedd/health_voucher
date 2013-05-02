class AddCodeIndexesToCardsAndVouchers < ActiveRecord::Migration
  def change
    add_index :cards, :serial_number
    add_index :vouchers, :code
  end
end
