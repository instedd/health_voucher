class Mentor::CsvExporter < CsvExporter
  include CardsHelper

  def initialize(mentor)
    @mentor = mentor
  end

  def export
    headers "# AGEP ID", "Current Card", "Validity"
    generate do |csv|
      @mentor.patients.order(:agep_id).each do |patient|
        csv << [patient.agep_id, card_serial_number(patient.current_card), 
                patient.current_card.try(:validity)]
      end
    end
  end
end

