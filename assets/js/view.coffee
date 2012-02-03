class App.View extends Backbone.View
  hasRendered: false
  
  render: =>
    $(@el).html App.Template[@template](this) if @template?
    
    unless @hasRendered
      Backbone.ModelBinding.bind this
      @hasRendered = true

    this
