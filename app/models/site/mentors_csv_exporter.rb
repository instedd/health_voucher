class Site::MentorsCsvExporter < CsvExporter
  def initialize(mentors)
    @mentors = mentors
  end

  def export
    headers "# Name", "# of AGEP IDs", "without card"
    generate do |csv|
      @mentors.each do |mentor|
        csv << [mentor.name, mentor.patients.count, mentor.patients.without_card.count]
      end
    end
  end
end


