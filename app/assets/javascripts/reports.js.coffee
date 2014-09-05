class ReportPage
  constructor: ->
    @form = $('#report_grouping_form')
    @site_combo = $('#site_id')
    @by_site_radio = $('#by_site')
    @by_mentor_radio = $('#by_mentor')
    @by_clinic_radio = $('#by_clinic')
    @export_button = $('.fexport[data-action]')

  submit: =>
    @form.trigger('submit.rails')

  init: ->
    @by_site_radio.on 'click', =>
      @site_combo.attr('disabled', true)
      @submit()
    @by_clinic_radio.on 'click', =>
      @site_combo.attr('disabled', false)
      @submit()
    @by_mentor_radio.on 'click', =>
      @site_combo.attr('disabled', false)
      @submit()
    @site_combo.on 'change', @submit
    $('#since, #until').on 'change', @submit

    @export_button.on 'click', =>
      url = @export_button.data('action')
      formData = @form.serialize()
      window.location = url + '?' + formData


class TransactionsReport extends ReportPage
  init: ->
    super()

    self = @
    $('#report_container').on 'click', '.group_by_clinic', ->
      self.select_site $(@).data('id')

  select_site: (id) ->
    @site_combo.attr('disabled', false)
    @site_combo.val(id)
    @by_clinic_radio.attr('checked', 'checked')
    @submit()
    

@onReportsCardAllocation = ->
  report = new ReportPage
  report.init()
  
@onReportsTransactions = ->
  report = new TransactionsReport
  report.init()

@onReportsServices = ->
  report = new ReportPage
  report.init()

  $('.scrollbarContainer > .horizontalScrollbar').width($('.report-table').width())
  $('.scrollbarContainer').on 'scroll', =>
    $('.tablewrapp').scrollLeft($('.scrollbarContainer').scrollLeft())
  $('.tablewrapp').on 'scroll', =>
    $('.scrollbarContainer').scrollLeft($('.tablewrapp').scrollLeft())

@onReportsClinics = ->
  report = new ReportPage
  report.init()
