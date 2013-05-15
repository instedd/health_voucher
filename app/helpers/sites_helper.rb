module SitesHelper
  def options_for_site_selector(path_helper, current = nil)
    sites = Site.order(:name).all.map do |site|
      path = Rails.application.routes.url_helpers.send(path_helper, site)
      current = path if current == site
      [site.name, path]
    end
    options_for_select(sites, current)
  end

  def assigned_patients_percent(site)
    patients = site.patients.count
    assigned = site.patients_with_cards.count

    if patients > 0
      100.0 * (patients - assigned) / patients
    else
      0
    end
  end
end
