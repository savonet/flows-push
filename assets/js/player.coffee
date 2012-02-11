soundManager.debugMode     = false
soundManager.hasPriority   = true
soundManager.url           = "swf/soundmanager2.swf"
soundManager.useHTML5Audio = true

class App.Player
  _.extend this.prototype, Backbone.Events

  constructor: ->
    @bind "toggle", @toggle

  toggle: =>
    @sound?.togglePause()

  destroy: =>
    url = @url
    
    @sound?.destruct()
    delete @sound
    delete @url

    @trigger "destroyed", url

  load: (url) =>
    return if url is @url

    unless soundManager.ok()
      return @trigger "error", "SoundManager2 isn't ready."

    @destroy()

    @sound = soundManager.createSound
      autoPlay     : true
      id           : url
      onfinish     : => @trigger "finished",    @sound
      onplay       : => @trigger "played",      @sound
      onpause      : => @trigger "paused",      @sound
      onresume     : => @trigger "resumed",     @sound
      onstop       : => @trigger "stopped",     @sound
      url          : url
      whileplaying : => @trigger "playing",     @sound
      whileloading : => @trigger "bytesLoaded", @sound

    @url = url

    @trigger "loaded", url

  playing: => @sound?.playState == 1
