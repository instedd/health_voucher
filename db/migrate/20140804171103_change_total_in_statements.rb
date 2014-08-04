class ChangeTotalInStatements < ActiveRecord::Migration
  def up
    change_column :statements, :total, :decimal, :precision => 10, :scale => 2

    connection.execute %(
      UPDATE statements SET total = (
        SELECT sum(amount) FROM transactions WHERE transactions.statement_id = statements.id
      )
    )
  end

  def down
    change_column :statements, :total, :decimal
  end
end
