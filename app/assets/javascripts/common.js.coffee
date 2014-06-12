$ ->
  $('.ItemTable').on('click', 'tr', (evt) ->
    if evt.target.tagName in ['A', 'BUTTON', 'INPUT', 'SELECT', 'LABEL'] or \
        $(evt.target).hasClass('no-link')
      return
    url = $(@).data('action')
    if url
      window.location.href = url
  )

  $('table').each (index, table) ->
    $('col', table).each (index, col) ->
      if $(col).hasClass('noprint')
        $("tr td:nth-child(#{index + 1}), tr th:nth-child(#{index + 1})", table).addClass('noprint')

  $(document).on('click', '.print_self', ->
    window.print()
  )

  $('input[type=checkbox].filtersSelectAll').each ->
    label = $(@).parent()
    checkboxes = label.siblings('label').children('input[type=checkbox]')

    setup_all_checkbox = =>
      all_checked = checkboxes.filter(':checked').size() == checkboxes.size()
      $(@).prop('checked', all_checked)
      label.children('span').html(if all_checked then 'Select none' else 'Select all')

    $(@).change (e) =>
      checked = $(@).is(':checked')
      checkboxes.prop('checked', checked)
      label.children('span').html(if checked then 'Select none' else 'Select all')

    checkboxes.change(setup_all_checkbox)

    setup_all_checkbox()

  $('.ux-select2').each ->
    $(@).select2()

@wireCheckboxGroup = (root, check_selector, all_check_selector, callback) ->
  root = root || $(document)
  check_selector = check_selector || 'input[type=checkbox]'
  all_check_selector = all_check_selector || '.check_all'

  last_clicked = null
  root.on('click', check_selector, (evt) ->
    if evt.shiftKey and last_clicked and last_clicked != this
      checks = root.find(check_selector)
      inside = false
      clicked = this
      checks = checks.filter ->
        if inside
          inside = (this != clicked) && (this != last_clicked)
        else
          inside = (this == clicked) || (this == last_clicked)
        inside
      checks.attr 'checked', clicked.checked
    else
      last_clicked = @
    root.find(all_check_selector).attr('checked', root.find(check_selector).filter(':not(:checked)').length == 0)

    runCallback()
  )

  root.on('click', all_check_selector, ->
    root.find(check_selector).attr('checked', @checked)
    runCallback()
  )

  runCallback = ->
    return if !callback
    all_checked = root.find(all_check_selector).attr('checked')
    some_checked = root.find(check_selector).filter(':checked').length > 0
    callback(all_checked, some_checked)


class @Collapsable
  constructor: (@root, @group) ->
    @root.find('.cancel_action').click =>
      @collapse()
    @root.find('span:first-child > a').click (evt) =>
      evt.stopImmediatePropagation()
      @toggle() unless $(evt.target).hasClass('disabled')

  collapse: ->
    @root.addClass('collapsed')
    @root.removeClass(@root.data('on-expanded'))

  expand: ->
    @root.removeClass('collapsed')
    @root.addClass(@root.data('on-expanded'))
    if @group
      $.each(@group, (idx, other) =>
        other.collapse() unless other == @
      )

  toggle: ->
    if @root.hasClass('collapsed')
      @expand()
    else
      @collapse()

