# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
@onTransactionsIndex = ->
  dialog = new FloatingDialog($('#update_status_dialog'))

  dialog.form.submit ->
    dialog.hide()
    false

  $('.transactions a.fedit').click ->
    row = $(@).parents('tr').first()
    dialog.form.attr('action', $(@).data('action'))
    $("##{$(@).text().trim()}_status").attr('checked', true)
    $("#comment").val(row.find('.comment').attr('title'))
    pos = $(@).position()
    dialog.show_at(pos)

