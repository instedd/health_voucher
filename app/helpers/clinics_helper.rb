module ClinicsHelper
  def clinics_by_site
    Hash[Site.all.map do |site|
      [site.id, site.clinics.order(:name).map do |clinic|
        [clinic.id, clinic.name]
      end]
    end]
  end

  def clinics_for_select(site, current = nil)
    options_from_collection_for_select(site.clinics.order(:name).all, :id, :name, current)
  end

  def service_type_span(service)
    content = case service.service_type
              when "primary"
                'P'
              when "secondary"
                'S'
              end
    content_tag(:span, content, { :class => "service_type #{service.service_type}" })
  end
end
