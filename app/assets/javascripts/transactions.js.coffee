@onTransactionsIndex = ->
  dialog = new RowDialog($('#update_status_dialog'))

  $('.transactions').on('click', 'a.fedit:not(.disabled)', (evt) ->
    row = $(@).parents('tr').first()
    $("##{$(@).text().trim()}_status").attr('checked', true)
    $("#comment").val(row.find('.comment').attr('title'))

    dialog.setup_and_show(evt)
  )
