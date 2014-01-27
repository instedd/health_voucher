class ActivitiesController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :add_breadcrumbs

  def index
    since_date = Date.parse_human_param(params[:since]).beginning_of_day rescue nil
    until_date = Date.parse_human_param(params[:until]).end_of_day rescue nil

    list = Activity.for_listing
    list = list.where('activities.user_id = ?', params[:user_id]) if params[:user_id].present?
    list = list.where('activities.object_class = ?', params[:object_class]) if params[:object_class].present?
    list = list.where('activities.created_at >= ?', since_date) if since_date.present?
    list = list.where('activities.created_at <= ?', until_date) if until_date.present?

    if params[:object_id].present?
      if params[:object_id].match /\d*-\d*/
        lower, upper = params[:object_id].split('-')
        list = list.where('activities.object_id >= ?', lower) if lower.present?
        list = list.where('activities.object_id <= ?', upper) if upper.present?
      else
        ids = params[:object_id].split(',')
        list = list.where('activities.object_id' => ids)
      end
    end

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
