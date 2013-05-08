module SitesHelper
  def options_for_site_selector(path_helper, current = nil)
    sites = Site.order(:name).all.map do |site|
      path = Rails.application.routes.url_helpers.send(path_helper, site)
      current = path if current == site
      [site.name, path]
    end
    options_for_select(sites, current)
  end
end
