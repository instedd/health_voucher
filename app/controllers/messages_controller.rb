class MessagesController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :add_breadcrumbs

  def index
    since_date = Date.parse_human_param(params[:since]).beginning_of_day rescue nil
    until_date = Date.parse_human_param(params[:until]).end_of_day rescue nil

    list = Message.for_listing
    list = list.where('messages.from LIKE ?', "%#{params[:from]}%") if params[:from].present?
    list = list.where('messages.message_type = ?', params[:type]) if params[:type].present?
    list = list.where('messages.status = ?', params[:status]) if params[:status].present?
    list = list.where('messages.created_at >= ?', since_date) if since_date.present?
    list = list.where('messages.created_at <= ?', until_date) if until_date.present?

    direction = if %w(asc desc).include?(params[:direction])
                  params[:direction]
                else
                  'desc'
                end
    sort = case params[:sort]
           when 'date'
             'messages.created_at'
           when 'from'
             'messages.from'
           when 'type'
             'messages.message_type'
           when 'status'
             'messages.status'
           else
             'messages.created_at'
           end
    if sort.present?
      list = list.reorder("#{sort} #{direction}")
    end
    @messages = list.page params[:page]
  end

  private

  def add_breadcrumbs
    @show_breadcrumb = true
    add_breadcrumb 'Incoming SMSs', messages_path
  end
end
