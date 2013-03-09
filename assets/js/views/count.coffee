class App.View.Count extends App.View
  tagName: "p"

  initialize: ->
    super

    @bindTo @collection, "add remove reset", @render

  render: ->
    @$el.text "#{@collection.size()} radios"
