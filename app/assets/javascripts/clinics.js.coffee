@onClinicsShow = ->
  cost_dialog = new FloatingDialog($('#cost_dialog'))

  cost_dialog.form.submit ->
    $.ajax({
      url: cost_dialog.form.attr('action'),
      type: 'post',
      dataType: 'script',
      data: cost_dialog.form.serialize()
    })
    cost_dialog.hide()
    false

  $('.clinic_services table').on('click', 'a.fedit', ->
    row = $(@).parents('tr').first()
    cost_dialog.form.attr('action', $(@).data('action'))
    cost_dialog.form.find('[name=service_id]').val($(@).data('service-id'))
    cost_dialog.form.find('[name=cost]').val(row.find('.cost').text())
    pos = $(@).position()
    cost_dialog.show_at(pos)
  )

