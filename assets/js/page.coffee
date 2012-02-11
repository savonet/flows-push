class App.Page extends App.View
  views: {}

  show: =>
    $(@target).html @render().el

    @populate() if @populate?

    _.each _(@views).values(), (view) -> view.render()

    this
