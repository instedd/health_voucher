class RenameVouchersColumns < ActiveRecord::Migration
  def up
    rename_column :vouchers, :panel, :service_type
  end

  def down
    rename_column :vouchers, :service_type, :panel
  end
end
