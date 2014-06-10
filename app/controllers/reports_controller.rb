class ReportsController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :add_breadcrumbs

  def card_allocation
    if request.format.html?
      params[:since] = 7.days.ago.to_date.to_human_param if params[:since].nil?
      params[:until] = Date.today.to_human_param if params[:until].nil?
    end

    @report = Report::CardAllocation.build params
  end

  def transactions
    if request.format.html?
      params[:since] = 30.days.ago.to_date.to_human_param if params[:since].nil?
      params[:until] = Date.today.to_human_param if params[:until].nil?
    end

    @report = Report::Transactions.build params
    @report_partial = "transactions_per_#{@report.by}"
  end

  def services
    if request.format.html?
      params[:since] = 1.month.ago.beginning_of_month.to_date.to_human_param if params[:since].nil?
      params[:until] = 1.month.ago.end_of_month.to_date.to_human_param if params[:until].nil?
    end

    @report = Report::Services.build params
  end

  def clinics
    if request.format.html?
      params[:since] = 1.month.ago.beginning_of_month.to_date.to_human_param if params[:since].nil?
      params[:until] = 1.month.ago.end_of_month.to_date.to_human_param if params[:until].nil?
    end

    @report = Report::Clinics.build params
  end

  private

  def add_breadcrumbs
    @show_breadcrumb = true
    add_breadcrumb 'Reports', reports_path
  end
end
