class Site::ClinicsCsvExporter < CsvExporter
  def initialize(clinics)
    @clinics = clinics
  end

  def export
    headers "# Name", "# of providers", "# of services"
    generate do |csv|
      @clinics.each do |clinic|
        csv << [clinic.name, clinic.providers.count, clinic.enabled_clinic_services.count]
      end
    end
  end
end

