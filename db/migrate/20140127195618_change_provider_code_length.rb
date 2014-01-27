class ChangeProviderCodeLength < ActiveRecord::Migration
  def up
    connection.execute "UPDATE providers SET code = CONCAT(code, '0')"
  end

  def down
    connection.execute "UPDATE providers SET code = SUBSTR(code, 1, 3)"
  end
end
