{Radio, User} = require "schema/model"
{clean} = require "lib/flows/utils"

exportRadio = (radio) ->
  delete radio.id
  radio.streams = (clean stream for stream in radio.streams)
  clean radio

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
    radios = (exportRadio radio for radio in radios)

    fn radios, null

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
    for user in users
      user.radios = user.radios or []
      user.radios = (exportRadio radio for radio in user.radios)
      user.user = user.username
      delete user.username
      delete user.id

    fn users, null
