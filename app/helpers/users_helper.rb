module UsersHelper
  def possible_site_managers_for_select
    options_from_collection_for_select(User.possible_managers.order(:email), :id, :email)
  end

  def short_role(role)
    case role.to_s
    when "site_manager"
      "Site Mgr"
    else
      role.to_s.capitalize
    end
  end
end
