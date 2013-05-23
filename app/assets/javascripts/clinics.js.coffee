@onClinicsShow = ->
  cost_dialog = new RowDialog($('#cost_dialog'))

  $('.clinic_services table').on('click', 'a.fedit', ->
    row = $(@).parents('tr').first()

    cost_dialog.form.find('[name=service_id]').val($(@).data('service-id'))
    cost_dialog.form.find('[name=cost]').val(row.find('.cost').text())

    cost_dialog.setup_and_show(@)
  )

