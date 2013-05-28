@onTransactionsIndex = ->
  dialog = new RowDialog($('#update_status_dialog'))

  $('.transactions').on('click', 'a.fedit:not(.disabled)', (evt) ->
    row = $(@).parents('tr').first()
    $("##{$(@).text().trim()}_status").attr('checked', true)
    $("#comment").val(row.find('.comment').attr('title'))

    dialog.setup_and_show(evt)
  )

  site_select = $('select#site_id')
  clinic_select = $('select#clinic_id')

  site_select.change ->
    load_clinics(@value)

  default_options = clinic_select.children().first().clone()

  load_clinics = (id) ->
    clinic_select.empty()
    clinic_select.append(default_options.clone())
    if Clinics[id]
      $.each(Clinics[id], (index, clinic) ->
        option = $('<option>').attr('value', clinic[0]).text(clinic[1])
        clinic_select.append(option)
      )

