class App.View.Count extends App.View
  tagName: "p"

  initialize: ->
    super

    @bindTo @collection, "add",    @render
    @bindTo @collection, "remove", @render
    @bindTo @collection, "reset",  @render

  render: ->
    @$el.text "#{@collection.size()} radios"
