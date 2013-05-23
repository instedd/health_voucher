class @FloatingDialog
  constructor: (@div) ->
    @title = @div.find('span a')
    @title.click =>
      @hide()
    @form = @div.find('form')
    @focus = @div.find('[data-focus]')
    @visible = false

  show: ->
    @div.css('display', 'block')
    @visible = true

  show_at: (pos) ->
    @show()
    offset = @title.position()
    @div.css('top', pos.top - offset.top)
    @div.css('left', pos.left - offset.left)
    @focus[0].focus() if @focus.length > 0

  hide: ->
    @div.css('display', 'none')
    @visible = false
    if @onHide
      @onHide()

class @RowDialog extends @FloatingDialog
  setup_and_show: (source) ->
    source = $(source)
    if @visible
      @hide()
      
    @form.attr('action', source.data('action'))
    @show_at(source.position())

    row = source.parents('tr').first()
    row.addClass('active')
    @onHide = ->
      row.removeClass('active')

