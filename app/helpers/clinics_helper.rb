module ClinicsHelper
  def clinics_by_site
    Hash[Site.all.map do |site|
      [site.id, site.clinics.order(:name).map do |clinic|
        [clinic.id, clinic.name]
      end]
    end]
  end
end
