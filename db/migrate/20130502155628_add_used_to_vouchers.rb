class AddUsedToVouchers < ActiveRecord::Migration
  def change
    add_column :vouchers, :used, :boolean, :default => false
  end
end
