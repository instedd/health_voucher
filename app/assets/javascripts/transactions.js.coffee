@onTransactionsIndex = ->
  dialog = new FloatingDialog($('#update_status_dialog'))

  dialog.form.submit ->
    $.ajax({
      url: dialog.form.attr('action'),
      type: 'post',
      dataType: 'script',
      data: dialog.form.serialize()
    })
    dialog.hide()
    false

  $('.transactions').on('click', 'a.fedit:not(.disabled)', ->
    row = $(@).parents('tr').first()
    dialog.form.attr('action', $(@).data('action'))
    $("##{$(@).text().trim()}_status").attr('checked', true)
    $("#comment").val(row.find('.comment').attr('title'))
    pos = $(@).position()
    dialog.show_at(pos)
    )

