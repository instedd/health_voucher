class AssignDialog
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
  assign = new AssignDialog($('#assign_dialog'))

  $('.assign_action').click ->
    assign.form.attr('action', $(@).data('action'))
    pos = $(@).position()
    assign.show_at(pos)

