class App.View.Radio extends App.View
  template: "radio"
  tagName: "table"
  attributes:
    border: 0

  events:
    "click a.sm2_button": "onPlay"

  initialize: ->
    super

    @bindTo @model,     "change",    @render
    @bindTo App.player, "toggle",    @onToggle
    @bindTo App.player, "loaded",    @syncPlayer
    @bindTo App.player, "destroyed", @syncPlayer

  getMime: (format) ->
    switch format.split("/").shift().toLowerCase()
      when "mp3"
        "audio/mp3"
      when "ogg"
        "application/ogg"
      when "aac", "aacplus", "he-aac", "aac+"
        "audio/aac"
      else
        ""

  onPlay: (e) =>
    e.preventDefault()

    el  = $(e.target)
    url = el.attr "href"

    if App.player.url == url && App.player.playing()
      App.player.destroy()
      @model.trigger "stop"
    else
      App.player.load url
      @model.trigger "play", @model

  syncPlayer: (url) =>
    @$("a.sm2_playing").removeClass "sm2_playing"
    @$("a[href=\"#{url}\"]").addClass "sm2_playing" if App.player.playing()

  onToggle: =>
    @$("a[href=\"#{App.player.url}\"]").toggleClass "sm2_playing"

  render: =>
    unless @hasRendered
      super

      @latestMetadata = @model.metadata()

      return this

    if @latestMetadata != @model.metadata()
      @latestMetadata == @model.metadata()
      @$(".metadata").fadeOut "slow", =>
        @$(".metadata").html(@latestMetadata).fadeIn "slow"

    this

  streams: =>
    token = @model.get "token"
    streams = "<ul>"
                                        
    _.each @model.get("streams"), (s) =>
      streams += "<li>"
     
      port = if window.location.port != "" then ":#{window.location.port}" else ""
      url  = "http://#{window.location.hostname}#{port}/radio/#{token}/#{s.format}"
      mime = @getMime s.format
      link = "<a href=\"#{url}\" type=\"#{mime}\">#{s.format}</a>"
      playerLink = "<a href=\"#{url}\" type=\"#{mime}\" class=\"sm2_button\"></a>"
      
      if soundManager.canPlayLink($(link).get(0)) and mime != "audio/aac"
        if url == App.player.url and App.player.playing()
          playerLink = "<a href=\"#{url}\" type=\"#{mime}\" class=\"sm2_button sm2_playing\"></a>"
        streams += playerLink
      streams += link

      streams += "</li>"
                                                                                                  
    streams += "</ul>"

class App.View.Radios extends App.View
  initialize: ->
    super

    @bindTo @collection, "add",    @render
    @bindTo @collection, "remove", @render
    @bindTo @collection, "reset",  @render
    @bindTo @collection, "change:last_seen", =>
      @slideFirst() if @collection.sortType == "last_seen"

    @views = {}

  slideFirst: =>
    old = @collection.models[0]
    return unless old?

    @collection.sort silent: true

    radio = @collection.models[0]

    return if radio.id == old.id

    if oldView = @views[radio.id]
      el = $(oldView.el).parent()
      el.slideUp "slow", =>
        oldView.unbindAll()
        el.remove()

    view = @views[radio.id] = new App.View.Radio(model: radio).render()
    
    $("<li></li>").append($(view.el)).hide().
      prependTo($(@el).find("ul.radios")).slideDown "slow"

  render: ->
    $(@el).empty()
    if @collection.isEmpty()
      $(@el).html "<b>No registered radio currently broadcasting!</b>"
      return this
 
    ul = $("<ul class=\"radios\"></ul>")
    _.each @collection.models, (radio) =>
      @views[radio.id]?.remove()
      
      @views[radio.id] = new App.View.Radio(model: radio).render()
      li = $("<li></li>").append @views[radio.id].el
      ul.append li

    $(@el).html ul

    basicMP3Player?.init()

    this
