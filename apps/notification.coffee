{io}    = require "../lib/flows/io"
redis   = require "../lib/flows/redis"
queries = require "../lib/flows/queries"
{clean} = require "../lib/flows/utils"

# / namespace is for notifications
io.sockets.on "connection", (socket) ->
  socket.on "join", (token) ->
    # special case: "flows" is a channel for all radios.
    all = token == "flows"

    if all
      socket.join "flows"
      return socket.emit "joined", "flows"
   
    if all
      d = new Date()
      d.setHours(d.getHours()-1)
      args =
        "last_seen.gte" : d
    else
      args =
        token : token

    queries.getRadios args, (err, radios) ->
      if err? or (not all and radios.length != 1)
        return socket.emit "error", "Could not join requested notification channel: a radio with ID #{token} does not seem to exist."
   
      socket.join token
      socket.json.emit "joined", (if all then radios else radios.shift())

redis.on "message", (channel, message) ->
  msg = clean JSON.parse message

  # Generic broadcast
  io.sockets.in("flows").json.emit "flows", msg

  # Specific broadcast
  if msg.radio?.token
    io.sockets.in(msg.radio.token).json.emit msg.radio.token, msg

