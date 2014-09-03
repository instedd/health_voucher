class AddTrainingToTransactions < ActiveRecord::Migration
  def up
    add_column :transactions, :training, :boolean, :null => false, :default => false

    connection.execute %(
      UPDATE transactions SET training = (
        SELECT (1 - (1 - clinic_sites.training) * (1 - card_sites.training))
        FROM authorizations
          INNER JOIN providers ON authorizations.provider_id = providers.id
          INNER JOIN clinics ON providers.clinic_id = clinics.id
          INNER JOIN sites clinic_sites ON clinic_sites.id = clinics.site_id
          INNER JOIN cards ON authorizations.card_id = cards.id
          INNER JOIN sites card_sites ON card_sites.id = cards.site_id
        WHERE authorizations.id = transactions.authorization_id
      )
    )
  end

  def down
    remove_column :transactions, :training
  end
end
