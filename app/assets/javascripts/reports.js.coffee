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

  $('#report_container').on 'click', '.group_by_clinic', ->
    id = $(this).data('id')
    site_combo.attr('disabled', false)
    site_combo.val(id)
    by_clinic_radio.attr('checked', 'checked')
    submit()


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
  $('#month, #year').on 'change', submit

