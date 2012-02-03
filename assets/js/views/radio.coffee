class App.View.Radio extends App.View
  template: "radio"
  tagName: "table"
  attributes:
    border: 0

  hasRendered: false

  initialize: ->
    super

    @model.bind "change", @render

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

  metadata: =>
    metadata = "<span class=\"title\">#{@model.get "title"}</span>"

    artist = @model.get "artist"
    if artist?
      metadata = "#{artist} &mdash; #{metadata}"

    metadata

  render: =>
    unless @hasRendered
      super

      Backbone.ModelBinding.bind this

      return this

    @$(".metadata").fadeOut "slow", =>
      @$(".metadata").html(@metadata()).fadeIn "slow"

    this

  streams: =>
    token = @model.get "token"
    streams = "<ul>"
                                        
    _.each @model.get("streams"), (s) =>
      streams += "<li>"
      
      url  = "http://#{window.location.hostname}:#{window.location.port}/radio/#{token}/#{s.format}"
      mime = @getMime s.format
      link = "<a href=\"#{url}\" type=\"#{mime}\">#{s.format}</a>"
      playerLink = "<a href=\"#{url}\" type=\"#{mime}\" class=\"sm2_button\"></a>"
      
      if soundManager.canPlayLink($(link).get(0)) and mime != "audio/aac"
        streams += playerLink
      streams += link

      streams += "</li>"
                                                                                                  
    streams += "</ul>"

class App.View.Radios extends App.View
  tagName: "ul"

  initialize: ->
    super

    @collection.bind "add",   @render
    @collection.bind "reset", @render
  
  render: ->
    $(@el).empty()
    if @collection.isEmpty()
      $(@el).html "<b>No registered radio currently broadcasting!</b>"
    else
      _.each @collection.models, (radio) =>
        view = new App.View.Radio model: radio
        li = $("<li></li>").append view.render().el
        $(@el).append li

    $("#radios").html @el
    
    basicMP3Player?.init()

    this
