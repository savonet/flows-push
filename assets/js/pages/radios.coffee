class App.Page.Radios extends App.Page
  template: "radios"

  initialize: =>
    @radios = new App.Collection.Radios

    @views.map     = new App.View.Map    collection: @radios
    @views.radios  = new App.View.Radios collection: @radios
    @views.twitter = new App.View.Twitter

    @radios.fetch()

  populate: =>
    @$(".map").html      @views.map.el
    @$(".radios").html   @views.radios.el
    @$(".twitter").after @views.twitter.el
