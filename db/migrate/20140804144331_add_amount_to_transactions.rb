class AddAmountToTransactions < ActiveRecord::Migration
  def up
    connection.transaction do
      add_column :transactions, :amount, :decimal, :precision => 10, :scale => 2

      connection.execute %(UPDATE transactions SET amount = (
        SELECT clinic_services.cost 
        FROM clinic_services, authorizations, providers, clinics 
        WHERE 
          transactions.authorization_id = authorizations.id AND 
          authorizations.provider_id = providers.id AND 
          providers.clinic_id = clinics.id AND 
          clinic_services.clinic_id = clinics.id AND 
          authorizations.service_id = clinic_services.service_id)
      )
    end
  end

  def down
    remove_column :transactions, :amount
  end
end
