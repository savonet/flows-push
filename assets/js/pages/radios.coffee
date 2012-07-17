class App.Page.Radios extends App.Page
  target:   "#main div.content"
  template: "radios"

  events:
    "click a.toggle-map": "toggleMap"

  initialize: =>
    @views.map     = new App.View.Map    collection: @collection
    @views.radios  = new App.View.Radios collection: @collection
    @views.count   = new App.View.Count  collection: @collection

  populate: =>
    @$(".map").append  @views.map.el
    @$(".count").html  @views.count.el
    @$(".radios").html @views.radios.el
    @$(".tabs").tabs()

  toggleMap: (e) =>
    e.preventDefault()

    target = $(e.target)

    if target.next().is(":visible")
      target.next().fadeOut "slow", ->
        target.text "(show map)"
    else
      target.next().fadeIn "slow", ->
        target.text "(hide map)"
