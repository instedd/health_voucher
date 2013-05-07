@onCardsIndex = ->
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
      $('#quantity').val(info.quantity).
        attr('min', 1).attr('max', info.quantity)

  one_submit = submit_elements('#serial_number')
  one_submit.attr('disabled', true)

  $('#serial_number').keyup ->
    one_submit.attr('disabled', !@value)

  last_clicked = null
  $('.return_card').click (evt) ->
    if evt.shiftKey and last_clicked and last_clicked != this
      checks = $('.return_card')
      inside = false
      clicked = this
      checks = checks.filter ->
        if inside
          inside = (this != clicked) && (this != last_clicked)
        else
          inside = (this == clicked) || (this == last_clicked)
        inside
      checks.attr 'checked', clicked.checked
    else
      last_clicked = @

  $('.serial_number').change ->
    @value = pad(@value, 6)

  pad = (n, width, z) ->
    z = z || '0'
    n = n + ''
    if n.length >= width
      n
    else
      new Array(width - n.length + 1).join(z) + n

