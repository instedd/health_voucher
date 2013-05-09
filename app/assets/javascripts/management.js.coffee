class ManagementDialog
  constructor: (@div) ->
    @title = @div.find('span a')
    @title.click =>
      @hide()
    @form = @div.find('form')

  show: ->
    @div.css('display', 'block')

  show_at: (pos) ->
    @show()
    offset = @title.position()
    @div.css('top', pos.top - offset.top)
    @div.css('left', pos.left - offset.left)

  hide: ->
    @div.css('display', 'none')

@onManagementIndex = ->
  assign = new ManagementDialog($('#assign_dialog'))
  start = new ManagementDialog($('#start_dialog'))
  report = new ManagementDialog($('#report_dialog'))

  $('.assign_action').click ->
    assign.form.attr('action', $(@).data('action'))
    pos = $(@).position()
    assign.show_at(pos)

  $('.start_action').click ->
    start.form.attr('action', $(@).data('action'))
    pos = $(@).position()
    start.show_at(pos)

  $('.report_action').click ->
    report.form.attr('action', $(@).data('action'))
    report.div.find('.serial_number').text($(@).data('serial-number'))
    pos = $(@).position()
    report.show_at(pos)
