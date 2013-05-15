class @FloatingDialog
  constructor: (@div) ->
    @title = @div.find('span a')
    @title.click =>
      @hide()
    @form = @div.find('form')
    @focus = @div.find('[data-focus]')

  show: ->
    @div.css('display', 'block')

  show_at: (pos) ->
    @show()
    offset = @title.position()
    @div.css('top', pos.top - offset.top)
    @div.css('left', pos.left - offset.left)
    @focus[0].focus() if @focus.length > 0

  hide: ->
    @div.css('display', 'none')


