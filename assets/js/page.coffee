class App.Page extends App.View
  views: {}

  show: =>
    $("#main div.content").html @render().el

    @populate()

    _.each _(@views).values(), (view) -> view.render()

    this
