bindCSVExport = ->
  $('.fexport[data-action]').on 'click', ->
    url = $(@).data('action')
    formData = $('#report_grouping_form').serialize()
    window.location = url + '?' + formData

@onReportsCardAllocation = ->
  form = $('#report_grouping_form')
  by_site_radio = $('#by_site')
  by_mentor_radio= $('#by_mentor')
  site_combo = $('#site_id')

  submit = ->
    form.trigger('submit.rails')

  by_site_radio.on 'click', ->
    site_combo.attr('disabled', true)
    submit()
  by_mentor_radio.on 'click', ->
    site_combo.attr('disabled', false)
    submit()
  site_combo.on 'change', submit
  $('#since, #until').on 'change', submit

  bindCSVExport()


@onReportsTransactions = ->
  form = $('#report_grouping_form')
  by_site_radio = $('#by_site')
  by_clinic_radio= $('#by_clinic')
  site_combo = $('#site_id')

  submit = ->
    form.trigger('submit.rails')

  by_site_radio.on 'click', ->
    site_combo.attr('disabled', true)
    submit()
  by_clinic_radio.on 'click', ->
    site_combo.attr('disabled', false)
    submit()
  site_combo.on 'change', submit
  $('#since, #until').on 'change', submit

  $('#report_container').on 'click', '.group_by_clinic', ->
    id = $(this).data('id')
    site_combo.attr('disabled', false)
    site_combo.val(id)
    by_clinic_radio.attr('checked', 'checked')
    submit()

  bindCSVExport()


@onReportsServices = ->
  form = $('#report_grouping_form')
  by_site_radio = $('#by_site')
  by_clinic_radio= $('#by_clinic')
  site_combo = $('#site_id')

  submit = ->
    form.trigger('submit.rails')

  by_site_radio.on 'click', ->
    site_combo.attr('disabled', true)
    submit()
  by_clinic_radio.on 'click', ->
    site_combo.attr('disabled', false)
    submit()
  site_combo.on 'change', submit
  $('#since, #until').on 'change', submit

  $('.scrollbarContainer > .horizontalScrollbar').width($('.report-table').width())
  $('.scrollbarContainer').on 'scroll', =>
    $('.tablewrapp').scrollLeft($('.scrollbarContainer').scrollLeft())
  $('.tablewrapp').on 'scroll', =>
    $('.scrollbarContainer').scrollLeft($('.tablewrapp').scrollLeft())

  bindCSVExport()


@onReportsClinics = ->
  form = $('#report_grouping_form')
  site_combo = $('#site_id')

  submit = ->
    form.trigger('submit.rails')

  site_combo.on 'change', submit
  $('#since, #until').on 'change', submit

  bindCSVExport()

