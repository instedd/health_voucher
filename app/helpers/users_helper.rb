module UsersHelper
  def possible_site_managers_for_select
    options_from_collection_for_select(User.possible_managers.order(:email), :id, :email)
  end
end
