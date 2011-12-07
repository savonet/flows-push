{io}    = require "lib/flows/io"
redis   = require "lib/flows/redis"
queries = require "lib/flows/pg"

# / namespace is for notifications
io.sockets.on "connection", (socket) ->
  socket.on "join", (id) ->
    console.log id
    
    # special case: "flows" is a channel for all radios.
    if id == "flows"
      socket.join "flows"
      console.log "foo"
      return socket.emit "joined", "flows"
    
    id = parseInt id
    queries.radioById id, (radio, err) ->
      if err?
        return socket.emit "error", "Could not join requested notification channel: a radio with ID #{id} does not seem to exist."
    
      socket.join "#{id}"
      socket.json.emit "joined", radio

redis.on "message", (channel, message) ->
  msg = JSON.parse(message)

  # Generic broadcast
  io.sockets.in("flows").json.emit "flows", msg

  # Specific broadcast
  if msg.data? and msg.data.id?
    io.sockets.in("#{msg.data.id}").json.emit "#{msg.data.id}", msg

