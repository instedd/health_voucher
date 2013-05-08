class RenamePatientsTable < ActiveRecord::Migration
  def change
    rename_table :pacients, :patients
    rename_column :cards, :pacient_id, :patient_id
    rename_index :cards, :index_cards_on_pacient_id, :index_cards_on_patient_id
    rename_index :patients, :index_pacients_on_current_card_id, :index_patients_on_current_card_id
    rename_index :patients, :index_pacients_on_mentor_id, :index_patients_on_mentor_id
  end
end
