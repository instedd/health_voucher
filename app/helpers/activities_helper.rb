module ActivitiesHelper
  def users_filter_options(current = nil)
    options_for_select([['(All Users)', '']]) + users_for_select(current)
  end

  def users_for_select(current = nil)
    options_from_collection_for_select(User.where(:admin => true).order(:email), :id, :email, current)
  end

  def object_class_filter_options(current = nil)
    options_for_select([['(All)', ''], 'Site', 'Statement', 'Transaction', 'User'], current)
  end

  def activities_filter_empty?
    %w(user_id object_class object_id since until).all? do |key|
      params[key].blank?
    end
  end

  def clear_filter_activities_path
    activities_path(sort: params[:sort], direction: params[:direction])
  end
end
