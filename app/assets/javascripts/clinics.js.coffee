@onClinicsShow = ->
  cost_dialog = new FloatingDialog($('#cost_dialog'))

  $('.set_cost').click ->
    td = $(@).parents('td')
    cost_dialog.form.attr('action', $(@).data('action'))
    cost_dialog.form.find('[name=service_id]').val($(@).data('service-id'))
    pos = $(@).position()
    cost_dialog.show_at(pos)

  $('.service_enable').click ->
    # if @checked
    #   $(@).parents('tr').find('.set_cost').click()

