class @FloatingDialog
  constructor: (@div) ->
    @title = @div.find('span a')
    @title.click =>
      @hide()
    @form = @div.find('form')
    @focus = @div.find('[data-focus]')
    @visible = false

    $(document).click (evt) =>
      if @visible && $(evt.target).closest(@div).length == 0
        if evt.target.dialog_opened == @
          evt.target.dialog_opened = null
        else
          # HACK to avoid closing the dialog when clicking in the jQuery datepicker
          targetClass = evt.target.getAttribute('class') || ''
          if !targetClass.match(/ui-datepicker/) && $(evt.target).closest('#ui-datepicker-div').length == 0
            @hide()
    $(document).keydown (evt) =>
      if @visible && evt.keyCode == 27
        @hide()

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
  constructor: (@div) ->
    super(@div)
    if @form.attr('data-remote')
      @form.submit =>
        @hide()

  setup_and_show: (event) ->
    event.target.dialog_opened = @
    source = $(event.target)
    if @visible
      @hide()
      
    @form.attr('action', source.data('action'))
    @show_at(source.position())

    row = source.parents('tr').first()
    row.addClass('active')
    @onHide = ->
      row.removeClass('active')

