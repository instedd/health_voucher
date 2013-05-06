# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@onCardsIndex = ->
  $('#batch_id').change ->
    if @value
      info = availability[@value]
      if info
        $('#first_serial_number').val(info.first_serial_number)
        $('#quantity').val(info.quantity).attr('min', 1).attr('max', info.quantity)

  $('.serial_number').change ->
    @value = pad(@value, 6)

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

  pad = (n, width, z) ->
    z = z || '0'
    n = n + ''
    if n.length >= width
      n
    else
      new Array(width - n.length + 1).join(z) + n

