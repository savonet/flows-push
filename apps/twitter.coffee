bitly   = require "../lib/flows/bitly"
twitter = require "../lib/flows/twitter"
queries = require "../lib/flows/queries"
redis   = require "../lib/flows/redis"

redis.on "message", (channel, message) ->
  now = new Date()
  return if latestUpdate? and latestUpdate.getTime() + updateTimeout > now.getTime()

  msg = JSON.parse(message)

  radio = msg.radio

  if msg.cmd == "metadata"
    # Reject metadata without title.
    return unless radio.title?

    queries.getRadio { token : radio.token }, (err, radio) ->
      return console.log "Error getting radio: #{err}" if err?
      return unless radio.twitters? and radio.twitters.length > 0

      if radio.artist? and radio.artist != ""
        metadata = "#{radio.title} by #{radio.artist}"
      else
        metadata = radio.title

      status = "Listening to #{metadata} on #{radio.name}"

      getUrl = (fn) ->
        if radio.website?
          bitly radio.website, (err, shortUrl) ->
            if err?
              console.error "Bit.ly error: #{err}"
            
            return fn "" if err? or not shortUrl?
              
            fn " #{shortUrl}"

        else
          fn ""

      params = {}

      if radio.longitude? and radio.latitude?
        lat = parseInt radio.latitude
        long = parseInt radio.longitude
        params.coordinates = [lat, long]

      getUrl (url) ->
        if status.length + url.length > 140
          # We cut the status and add ".."
          len = 140 - url.length - 2
          status = "#{status.slice 0, len}.."

        status = "#{status}#{url}"
        twitter.updateStatus client, status for client in radio.twitters
