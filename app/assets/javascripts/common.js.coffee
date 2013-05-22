$ ->
  $('.ItemTable').on('click', 'tr', (evt) ->
    if evt.target.tagName in ['A', 'BUTTON']
      return
    url = $(@).data('action')
    if url
      window.location.href = url
  )

