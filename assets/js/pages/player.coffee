class App.Page.Player extends App.Page
  target:   ".player div.content"
  template: "player"

  events:
    "click a.play": "onClickPlay"

  initialize: ->
    @collection.bind "play",   @onPlay
    @collection.bind "stop",   @onStop
    @collection.bind "change", @onChange

  onClickPlay: (e) =>
    e.preventDefault()

    el = @$("a.play")
    if el.hasClass "sm2_playing"
      el.removeClass "sm2_playing"
    else
      el.addClass "sm2_playing"

    App.player.trigger "toggle"

  onPlay: (radio) =>
    @model = radio
    @render()

  onChange: (radio) =>
    return unless @model? and radio.id == @model.id
    @render()

  onStop: =>
    delete @model
    @render()

