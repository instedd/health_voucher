$ ->
  $('.site_selector select').change ->
    window.location = @value

@onSiteAssignCardsIndex = ->
  submit_elements = (selector) ->
    $('[type=submit]', $(selector)[0].form)

  batch_submit = submit_elements('#batch_id')
  batch_submit.attr('disabled', true)

  $('#batch_id').change ->
    batch_submit.attr('disabled', !@value)
    return unless @value
    info = availability[@value]
    if info
      $('#first_serial_number').val(info.first_serial_number)
      $('#quantity').val(Math.min(needed, info.quantity)).
        attr('min', 1).attr('max', info.quantity)

  one_submit = submit_elements('#serial_number')
  one_submit.attr('disabled', true)

  $('#serial_number').keyup ->
    one_submit.attr('disabled', !@value)

  @wireCheckboxGroup $('.unassigned-cards'), '.return_card', '.check_all', (all, some) ->
    $('.return_button').attr('disabled', !some)

@onEditManager = ->
  $('select#user_id').change ->
    $(@).parents('form').find('button').attr('disabled', !$(@).val())
