class App.Model.Radio extends App.Model
  idAttribute: "token"
  urlRoot: "radio"

  initialize: ->
    super

    @socket = io.connect "http://#{window.location.hostname}:#{window.location.port}"
    @socket.emit "join", @id

    @socket.on "joined", (radio) =>
      @set radio if radio.token == @id
    @socket.on @id, (data) =>
      @set data.radio if data.cmd == "metadata"

  metadata: =>
    metadata = "<span class=\"title\">#{@get "title"}</span>"

    artist = @get "artist"
    if artist?
      metadata = "#{artist} &mdash; #{metadata}"

    metadata

class App.Collection.Radios extends App.Collection
  model:  App.Model.Radio
  url:    "/radios"
 
  search: (test) =>
    @cache = @models unless @cache?

    @reset _.filter(@cache, test)

  searchAny: (text) =>
    rex = new RegExp text, "i"
    @search (model) -> _.any(_.values(model.attributes), (attr) -> "#{attr}".match(rex))

  fetch: =>
    delete @cache

    super

  sortType: "last_seen"
  comparator: (radio) =>
    if @sortType == "last_seen"
      -(new Date(radio.get "last_seen")).getTime()
    else
      radio.get @sortType
  sort: (options, type) =>
    @sortType = type if type?

    super
