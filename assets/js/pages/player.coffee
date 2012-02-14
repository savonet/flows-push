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

    App.player.toggle()

    el = @$("a.play")
    if App.player.playing el.attr("href")
      el.addClass "sm2_playing"
    else
      el.removeClass "sm2_playing"

  onPlay: (radio) =>
    @model = radio
    @render()

  onChange: (radio) =>
    return unless @model? and radio.id == @model.id
    @render()

  onStop: =>
    delete @model
    @render()

