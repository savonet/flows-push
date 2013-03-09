_                  = require "underscore"
{Listener, Radio, 
 Stream, User}     = require "../../schema/model"
{clean}            = require "./utils"
{getCity}          = require "./geoip"

exportStream = (stream) ->
  stream = _.clone stream
  delete stream.id
  clean stream

module.exports.exportRadio = exportRadio = (radio) ->
  radio = _.clone radio
  delete radio.id
  radio.streams  = (exportStream stream for stream in radio.streams)
  clean radio

module.exports.exportRadios = exportRadios = (radios) ->
  exportRadio radio for radio in radios

radiosParams =
  only    : [
    "id", "name", "token", "website",
    "title", "artist", "genre", "description",
    "longitude", "latitude", "last_seen"
  ]
  include : {
    streams : {
      only : [ "id", "format", "url", "msg" ]
    }
  }

module.exports.getRadios = (param, fn) ->
  Radio.find param, _.clone(radiosParams), fn

module.exports.getRadio = (param, fn) ->
  Radio.findOne param, _.clone(radiosParams), fn

module.exports.updateRadio = (token, radio, fn) ->
  Radio.update { token : token}, radio, fn

module.exports.destroyRadio = (token, fn) ->
  Radio.findOne { token : token }, _.clone(radiosParams), (err, radio) ->
    return fn err, null if err
    return fn "No such radio", null unless radio?

    Stream.destroy { radio_id : radio.id }, (err, results) ->
      return fn err, null if err
      Radio.destroy { token : token }, fn

createListener = (stream, ip, fn) ->
  getCity ip, (err, data) ->
    data ||=
      latitude  : null
      longitude : null

    Listener.create {
      stream_id : stream.id
      ip        : ip
      latitude  : data.latitude
      longitude : data.longitude
      last_seen : new Date() }, (err, result) ->
        return fn err, null if err?
        fn null, result

module.exports.getListener = (stream, ip, fn) ->
  Listener.findOne { 
    stream_id : stream.id,
    ip        : ip }, (err, listener) ->
      return fn err, null if err?
      return fn null, listener if listener?
      createListener stream, ip, fn

module.exports.updateListener = (listener) ->
  Listener.update { id : listener.id }, { last_seen : new Date() }, ->

module.exports.updateListener = (listener) ->
  Listener.update { id : listener.id }, { last_seen : new Date() }, ->

module.exports.exportUser = exportUser = (user) ->
  user = _.clone user
  delete user.id
  delete user.password
  user.user = user.username
  delete user.username
  user.radios = exportRadios(user.radios or [])
  clean user

module.exports.exportUsers = (users) ->
  exportUser user for user in users

module.exports.getUser = (param, fn) ->
  User.findOne param, {
    only    : [
      "id", "username", "password", "email",
      "last_seen", "last_ip"
    ]
    include : {
      radios : _.clone radiosParams
    }
  }, fn

module.exports.updateUser = (user, fn) ->
  User.update user.id, user, fn
