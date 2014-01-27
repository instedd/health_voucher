class Site::PatientsCsvExporter < CsvExporter
  include CardsHelper

  def initialize(patients)
    @patients = patients
  end

  def export
    headers "# Mentor", "AGEP ID", "Current Card", "Validity"
    generate do |csv|
      @patients.each do |patient|
        csv << [patient.mentor.name, patient.agep_id,
                card_serial_number(patient.current_card),
                patient.current_card.try(:validity)]
      end
    end
  end
end

