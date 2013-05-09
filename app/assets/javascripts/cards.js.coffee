$ ->
  $('.serial_number').change ->
    @value = pad(@value, 6)

  pad = (n, width, z) ->
    z = z || '0'
    n = n + ''
    if n.length >= width
      n
    else
      new Array(width - n.length + 1).join(z) + n

