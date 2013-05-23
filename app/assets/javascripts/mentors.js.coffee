@onMentorShow = ->
  assign = new RowDialog($('#assign_dialog'))
  start = new RowDialog($('#start_dialog'))
  report = new RowDialog($('#report_dialog'))

  $('.assign_action').click ->
    assign.setup_and_show(@)

  $('.start_action').click ->
    start.setup_and_show(@)

  $('.report_action').click ->
    report.div.find('.serial_number').text($(@).data('serial-number'))
    report.setup_and_show(@)

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
