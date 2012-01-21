crypto  = require "crypto"
{io}    = require "../lib/flows/io"
queries = require "../lib/flows/queries"
{clean} = require "../lib/flows/utils"

admin = io.of "/admin"

admin.on "connection", (socket) ->
  socket.on "sign-in", ({ user : user, password: password}) ->
    return socket.emit "error", "default user is not allowed to sign-in" if user == "default"
    
    params =
      username : user
      password : crypto.createHash("sha224").update(password).digest(encoding="hex")

    queries.getUsers params, (users, err) ->
      if err? or users.length != 1
        return socket.emit "error", "Sign-in failed!"


      user = users.shift()
      user.last_seen = new Date()
      user.last_ip   = socket.handshake.address.address

      queries.updateUser user, (err) ->
        socket.emit "error", "Sign-in failed!" if err?

        socket.user = queries.exportUser user
        return socket.emit "signed-in", socket.user

