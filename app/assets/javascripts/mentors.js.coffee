@onMentorShow = ->
  # Row floating dialogs
  assign = new RowDialog($('#assign_dialog'))
  start = new RowDialog($('#start_dialog'))
  expiration = new RowDialog($('#expiration_dialog'))
  report = new RowDialog($('#report_dialog'))
  unassign = new RowDialog($('#unassign_dialog'))
  destroy = new RowDialog($('#destroy_dialog'))

  # Floating dialogs activation
  $('table.patients').on('click', '.assign_action:not(.disabled)', (evt) ->
    assign.form.find('.serial_number').val(NextSerialNumber)
    assign.setup_and_show(evt)
  ).on('click', '.start_action', (evt) ->
    start.setup_and_show(evt)
  ).on('click', '.set_expiration', (evt) ->
    expiration.div.find('.expiration').val($(@).data('expiration'))
    expiration.setup_and_show(evt)
  ).on('click', '.report_action', (evt) ->
    report.div.find('.serial_number').text($(@).data('serial-number'))
    report.setup_and_show(evt)
  ).on('click', '.unassign_action', (evt) ->
    unassign.div.find('.serial_number').text($(@).data('serial-number'))
    unassign.setup_and_show(evt)
  ).on('click', '.destroy_action', (evt) ->
    destroy.setup_and_show(evt)
  )

  # Customize datepicker for validity dialog
  $('#start_dialog .ux-datepicker').datepicker('option', 'showOn', 'none')
  $('#expiration_dialog .ux-datepicker').datepicker('option', 'showOn', 'none')

  # Group of collapsable actions below list
  group = []
  $('.ux-collapsible').each (idx, elt) ->
    coll = new Collapsable($(elt), group)
    group.push(coll)
  move_collapsable = $.grep(group, (coll, idx) ->
    coll.root.find('.move_patients_action').length > 0
  )[0]
  batch_validate_collapsable = $.grep(group, (coll, idx) ->
    coll.root.find('.batch_validate_action').length > 0
  )[0]

  # Move patients dialog
  move_dialog = $('.move_dialog')
  move_dialog.find('select').change ->
    if @value
      move_dialog.find('button').attr('disabled', false)
    else
      move_dialog.find('button').attr('disabled', true)
  move_dialog.find('form').submit ->
    ids = $('.patient_check:checked').map(-> @value).toArray().join()
    $('#patient_ids').val(ids)
    true

  # Batch validate dialog
  batch_validate_dialog = $('.batch_validate_dialog')
  batch_validate_dialog.find('form').submit ->
    ids = $('.patient_check:checked').map(-> @value).toArray().join()
    $('#validate_patient_ids').val(ids)
    true

  # Connect move dialog enable to the active checkboxes
  toggleMove = (v) ->
    has_other_mentors = $('#target_id option').length > 1
    button = $('.move_patients_action .fright')
    if v && has_other_mentors
      button.removeClass('disabled')
    else
      button.addClass('disabled')

  toggleValidate = (v) ->
    button = $('.batch_validate_action .fplay')
    if v then button.removeClass('disabled') else button.addClass('disabled')

  @wireCheckboxGroup $('.patients'), '.patient_check', '.check_all',
    (all_checked, some_checked) ->
      toggleMove(some_checked)
      toggleValidate(some_checked)
      move_collapsable.collapse() unless some_checked || !move_collapsable
      batch_validate_collapsable.collapse() unless some_checked || !batch_validate_collapsable

  # Auto assign toggle enable
  nextSerialNumberUpdated()


@nextSerialNumberUpdated = ->
  $('#initial_serial_number').val(NextSerialNumber)

  if (!NextSerialNumber)
    $('table.patients').find('.assign_action').addClass('disabled')
    $('.auto_assign_action .fsettings').addClass('disabled')

