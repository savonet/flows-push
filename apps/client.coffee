_       = require "underscore"
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

    queries.getUser params, (user, err) ->
      if err? or not user?
        return socket.emit "error", "Sign-in failed!"

      forwardedIpsStr = socket.handshake.headers["x-forwarded-for"]
      if forwardedIpsStr?
        [address] = forwardedIpsStr.split ","
      address = address || socket.handshake.address.address

      user.last_seen = new Date()
      user.last_ip   = address

      queries.updateUser user, (err) ->
        socket.emit "error", "Sign-in failed!" if err?

        socket.user = _.clone user
        return socket.emit "signed-in", queries.exportUser(user)

  socket.on "get-user", ->
    return socket.emit "error", "You are not signed-in!" unless socket.user?
    queries.getUser { id : socket.user.id }, (user, err) ->
      return socket.emit "error" if err?
      socket.user = _.clone user
      socket.emit "user", queries.exportUser(user)

  socket.on "edit-radio", (radio) ->
    return socket.emit "error", "You are not signed-in!" unless socket.user?

    ok = _.any socket.user.radios, (check) ->
      radio.token == check.token
    return socket.emit "error", "No such radio!" unless ok

    queries.updateRadio radio.token, radio, (err, results) ->
      return socket.emit "error", err if err?

      return socket.emit "error", "Update failed" unless results == 1

      socket.emit "edited-radio"

  socket.on "delete-radio", (token) ->
    return socket.emit "error", "You are not signed-in!" unless socket.user?

    ok = _.any socket.user.radios, (radio) ->
      radio.token == token
    return socket.emit "error", "No such radio!" unless ok

    queries.destroyRadio token, (err, results) ->
      return socket.emit "error", err if err?

      return socket.emit "error", "Delete failed" unless results == 1

      socket.emit "deleted-radio"
