soundManager.debugMode     = false
soundManager.hasPriority   = true
soundManager.url           = "swf/soundmanager2.swf"
soundManager.useHTML5Audio = true

class App.Player
  _.extend this.prototype, Backbone.Events

  toggle: =>
    if @sound?
      @destroy()
    else
      @load @url if @url?

  destroy: =>
    return unless @sound?

    @sound.destruct()
    delete @sound

    @trigger "stopped", @url

  load: (url) =>
    return if @sound? and url is @url

    unless soundManager.ok()
      return @trigger "error", "SoundManager2 isn't ready."

    @destroy()

    @sound = soundManager.createSound
      autoPlay     : true
      id           : url
      url          : url

    @trigger "played", @url = url

  playing: (url = @url) =>
    @url == url and @sound? and not @sound.paused and @sound.playState == 1
