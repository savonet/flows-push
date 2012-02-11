class App.Page.Radios extends App.Page
  target:   "#main div.content"
  template: "radios"

  initialize: =>
    @views.map     = new App.View.Map    collection: @collection
    @views.radios  = new App.View.Radios collection: @collection

  populate: =>
    @$(".map").html      @views.map.el
    @$(".radios").html   @views.radios.el
