{Radio, User} = require "schema/model"
{clean} = require "lib/flows/utils"

module.exports.exportRadio = exportRadio = (radio) ->
  delete radio.id
  radio.streams = (clean stream for stream in radio.streams)
  clean radio

module.exports.exportRadios = exportRadios = (radios) ->
  exportRadio radio for radio in radios

radiosParams =
  order   : [ "name" ]
  only    : [
    "id", "name", "token", "website",
    "title", "artist", "genre", "description",
    "longitude", "latitude"
  ]
  include : {
    streams : {
      only : [ "format", "url", "msg" ]
    }
  }

module.exports.getRadios = (param, fn) ->
  Radio.find param, radiosParams, (err, radios) ->
  
    if err?
      return fn null, err

    radios = radios or []
    fn radios, null

module.exports.exportUser = exportUser = (user) ->
  delete user.id
  delete user.password
  user.user = user.username
  delete user.username
  user.radios = exportRadios(user.radios or [])
  clean user

module.exports.exportUsers = (users) ->
  exportUser user for user in users

module.exports.getUsers = (param, fn) ->
  User.find param, {
    only    : [
      "id", "username", "password", "email",
      "last_seen", "last_ip"
    ]
    include : {
      radios : radiosParams
    }
  }, (err, users) ->

    if err?
      return fn null, err

    users = users or []
    fn users, null

module.exports.updateUser = (user, fn) ->
  User.update user.id, user, fn
