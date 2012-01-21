bitly   = require "../lib/flows/bitly"
twitter = require "../lib/flows/twitter"
redis   = require "../lib/flows/redis"

# One update every 3 min..
updateTimeout = 3*60*1000
latestUpdate = new Date()

# Allow first update
latestUpdate.setTime latestUpdate.getTime() - updateTimeout

redis.on "message", (channel, message) ->
  now = new Date()
  return if latestUpdate? and latestUpdate.getTime() + updateTimeout > now.getTime()

  msg = JSON.parse(message)

  radio = msg.radio

  if msg.cmd == "metadata"
    # Reject metadata without title.
    return unless radio.title?

    if radio.artist? and radio.artist != ""
      metadata = "#{radio.title} by #{radio.artist}"
    else
      metadata = radio.title

    status = "On #{radio.name}: #{metadata}"

    getUrl = (fn) ->
      if radio.website?
        bitly radio.website, (shortUrl, err) ->
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
      end = " #savonetflows#{url}"

      if status.length + end.length > 140
        # We cut the status and add ".."
        len = 140 - end.length - 2
        status = "#{status.slice 0, len}.."

      status = "#{status} #savonetflows#{url}"

      twitter.updateStatus status, (err, data) ->
        if err?
          return console.error "Error while updating twitter status: #{err}"

        latestUpdate = now
