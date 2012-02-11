class App.View extends Backbone.View
  hasRendered: false

  bindTo: (obj, event, callback) =>
    obj.bind event, callback, this
    (@bindings ||= []).push
      event:    event
      obj:      obj
      callback: callback
      context:  this

  unbindAll: =>
    _.each @bindings, ({event: event, obj: obj, callback: callback, context: context}) ->
      obj.unbind event, callback, context

  render: =>
    $(@el).html App.Template[@template](this) if @template?
    
    @hasRendered = true

    Backbone.ModelBinding.bind this if @model?

    this
