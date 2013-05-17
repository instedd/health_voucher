@onMentorShow = ->
  assign = new FloatingDialog($('#assign_dialog'))
  start = new FloatingDialog($('#start_dialog'))
  report = new FloatingDialog($('#report_dialog'))

  $('.assign_action').click ->
    assign.form.attr('action', $(@).data('action'))
    pos = $(@).position()
    assign.show_at(pos)

  $('.start_action').click ->
    start.form.attr('action', $(@).data('action'))
    pos = $(@).position()
    start.show_at(pos)

  $('.report_action').click ->
    report.form.attr('action', $(@).data('action'))
    report.div.find('.serial_number').text($(@).data('serial-number'))
    pos = $(@).position()
    report.show_at(pos)

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
