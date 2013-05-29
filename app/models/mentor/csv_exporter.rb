require 'csv'

class Mentor::CsvExporter
  include CardsHelper

  def initialize(mentor)
    @mentor = mentor
  end

  def export
    CSV.generate do |csv|
      csv << ["# AGEP ID", "Current Card", "Validity"]
      @mentor.patients.order(:agep_id).each do |patient|
        csv << [patient.agep_id, card_serial_number(patient.current_card), 
                patient.current_card.try(:validity).try(:to_s)]
      end
    end
  end
end

