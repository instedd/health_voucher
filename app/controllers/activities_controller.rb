class ActivitiesController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :add_breadcrumbs

  def index
    list = Activity.for_listing

    direction = if %w(asc desc).include?(params[:direction]) 
                  params[:direction] 
                else 
                  'desc'
                end
    sort = case params[:sort]
           when 'date'
             'activities.created_at'
           when 'user'
             'users.email'
           when 'object_class'
             'activities.object_class'
           when 'object_id'
             'activities.object_id'
           else
             'activities.created_at'
           end
    if sort.present?
      list = list.reorder("#{sort} #{direction}")
    end
    @activities = list.page params[:page]
  end

  private

  def add_breadcrumbs
    @show_breadcrumb = true
    add_breadcrumb 'Activity Log', activities_path
  end
end
