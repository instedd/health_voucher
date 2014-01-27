class Site::ProvidersCsvExporter < CsvExporter
  include ApplicationHelper

  def initialize(providers)
    @providers = providers
  end

  def export
    headers "# Clinic", "Code", "Name", "Enabled"
    generate do |csv|
      @providers.each do |provider|
        csv << [provider.clinic.name, provider.code, provider.name, humanize_boolean(provider.enabled?)]
      end
    end
  end
end

