@onMentorShow = ->
  assign = new RowDialog($('#assign_dialog'))
  start = new RowDialog($('#start_dialog'))
  report = new RowDialog($('#report_dialog'))

  $('table.patients').on('click', '.assign_action:not(.disabled)', (evt) ->
    assign.form.find('.serial_number').val(NextSerialNumber)
    assign.setup_and_show(evt)
  ).on('click', '.start_action', (evt) ->
    start.setup_and_show(evt)
  ).on('click', '.report_action', (evt) ->
    report.div.find('.serial_number').text($(@).data('serial-number'))
    report.setup_and_show(evt)
  )

  move_dialog = $('.move_dialog')
  move_dialog.find('select').change ->
    if @value
      move_dialog.find('button').attr('disabled', false)
    else
      move_dialog.find('button').attr('disabled', true)
  move_dialog.find('form').submit ->
    ids = $('.patients input:checked').map(-> @value).toArray().join()
    $('#patient_ids').val(ids)
    true

  nextSerialNumberUpdated()

  $('.fsettings').on('click', (evt) ->
    if $(@).hasClass('disabled')
      evt.stopImmediatePropagation()
  )

  $('#start_dialog .ux-datepicker').datepicker('option', 'showOn', 'none')

@nextSerialNumberUpdated = ->
  $('#initial_serial_number').val(NextSerialNumber)

  if (!NextSerialNumber)
    $('table.patients').find('.assign_action').addClass('disabled')
    $('.auto_assign_action .fsettings').addClass('disabled')
