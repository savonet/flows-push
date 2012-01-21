{Listener, Radio, User} = require "../../schema/model"
{clean}                 = require "./utils"
{getPosition}           = require "./geoip"

exportStream = (stream) ->
  delete stream.id
  clean stream

module.exports.exportRadio = exportRadio = (radio) ->
  delete radio.id
  radio.streams = (exportStream stream for stream in radio.streams)
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
      only : [ "id", "format", "url", "msg" ]
    }
  }

module.exports.getRadios = (param, fn) ->
  Radio.find param, radiosParams, (err, radios) ->
    return fn null, err if err?

    radios = radios or []
    fn radios, null

createListener = (stream, ip, fn) ->
  getPosition ip, (data, err) ->
    data ||=
      latitude  : null
      longitude : null

    Listener.create {
      stream_id : stream.id
      ip        : ip
      latitude  : data.latitude
      longitude : data.longitude
      last_seen : new Date() }, (err, result) ->
        return fn null, err if err?
        fn result, null

module.exports.getListener = (stream, ip, fn) ->
  Listener.findOne { 
    stream_id : stream.id,
    ip        : ip }, (err, listener) ->
      return fn null, err if err?
      return fn listener, null if listener?
      createListener stream, ip, fn

module.exports.updateListener = (listener) ->
  Listener.update listener, { last_seen : new Date() }, ->

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
