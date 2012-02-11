class window.App
  @Template: {}

  constructor: ->
    @radios = new App.Collection.Radios
    @main    = (new App.Page.Radios  collection: @radios).show()
    @left    = (new App.Page.Actions collection: @radios).show()
    @player  = (new App.Page.Player  collection: @radios).show()
    @twitter = (new App.Page.Twitter).show()
    @radios.fetch()
