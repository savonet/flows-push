crypto  = require "crypto"
{io}    = require "lib/flows/io"
queries = require "lib/flows/queries"
{clean} = require "lib/flows/utils"

admin = io.of "/admin"

admin.on "connection", (socket) ->
  socket.on "sign-in", ({ user : user, password: password}) ->
    params =
      username : user
      password : crypto.createHash("sha224").update(password).digest(encoding="hex")

    queries.getUsers params, (users, err) ->
      console.log users
      console.log err
      if err? or users.length != 1
        return socket.emit "error", "Sign-in failed!"

      user = users.shift()

      socket.user = user
      return socket.emit "signed-in", user

