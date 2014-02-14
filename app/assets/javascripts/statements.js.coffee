@onStatementsIndex = ->
  setup_site_clinic_combos($('#site_id'), $('#clinic_id'))

  exportButton = $('.actions .fexport')

  @wireCheckboxGroup $('.statements'), '.stmt_check', null,
    (all_checked, some_checked) ->
      if some_checked
        exportButton.removeClass('disabled')
      else
        exportButton.addClass('disabled')

  exportButton.on 'click', ->
    if exportButton.hasClass('disabled')
      return

    ids = $('.stmt_check:checked').map(-> @value).toArray().join()
    $('#stmt_ids').val(ids)
    $('#export_stmts').submit()


@onStatementGenerate = ->
  setup_site_clinic_combos($('select.site'), $('select.clinic'))


setup_site_clinic_combos = (site_select, clinic_select) ->
  default_options = clinic_select.children().first().clone()

  site_select.change ->
    load_clinics(@value, default_options)

  load_clinics = (id, default_options) ->
    clinic_select.empty()
    clinic_select.append(default_options.clone())
    if Clinics[id]
      $.each(Clinics[id], (index, clinic) ->
        option = $('<option>').attr('value', clinic[0]).text(clinic[1])
        clinic_select.append(option)
      )

