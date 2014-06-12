@onStatementsIndex = ->
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


