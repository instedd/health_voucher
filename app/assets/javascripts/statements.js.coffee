@onStatementGenerate = ->
  site_select = $('select.site')
  clinic_select = $('select.clinic')

  site_select.change ->
    load_clinics(@value)

  default_options = clinic_select.children().clone()

  load_clinics = (id) ->
    clinic_select.empty()
    clinic_select.append(default_options.clone())
    $.each(Clinics[id], (index, clinic) ->
      option = $('<option>').attr('value', clinic[0]).text(clinic[1])
      clinic_select.append(option)
    )

