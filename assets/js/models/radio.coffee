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

class App.Collection.Radios extends App.Collection
  model: App.Model.Radio
  url: "/radios"
