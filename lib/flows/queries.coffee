_                  = require "underscore"
{Listener, Radio, 
 Stream, Twitter, 
 User}             = require "../../schema/model"
{clean}            = require "./utils"
{getPosition}      = require "./geoip"

exportStream = (stream) ->
  stream = _.clone stream
  delete stream.id
  clean stream

exportTwitter = (twitter) -> twitter.name

module.exports.exportRadio = exportRadio = (radio) ->
  radio = _.clone radio
  delete radio.id
  radio.streams  = (exportStream stream for stream in radio.streams)
  radio.twitters = (exportTwitter twitter for twitter in radio.twitters)
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
    twitters : {
      only : [ "id", "name" ]
    }
  }

module.exports.getRadios = (param, fn) ->
  Radio.find param, _.clone(radiosParams), (err, radios) ->
    return fn null, err if err?

    radios = radios or []
    fn radios, null

module.exports.getRadio = (param, fn) ->
  Radio.findOne param, _.clone(radiosParams), (err, radio) ->
    return fn null, err if err?

    fn radio, null

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
  Listener.update { id : listener.id }, { last_seen : new Date() }, ->

createTwitter = (radio, access, fn) ->
  Twitter.create {
    radio_id : radio.id
    name     : access.name
    token    : access.token
    secret   : access.secret }, (err, result) ->
      return fn null, err if err?
      fn result, null

module.exports.getTwitters = (radio, fn) ->
  Radio.findOne { token : radio.token }, (err, radio) ->
    return fn null, err if err?
    return fn null, null unless radio?

    Twitter.find { radio_id : radio.id }, (err, twitters) ->
      return fn null, err if err?
      fn twitters, null

module.exports.updateTwitter = (radio, access, fn) ->
  Twitter.findOne { radio_id : radio.id, name: access.name }, (err, twitter) ->
      return fn null, err if err?

      if twitter?
        return Twitter.update { id : twitter.id }, {
          token  : access.token
          secret : access.secret }, (err, result) ->
          return fn null, err if err?
          fn result, null
 
      createTwitter radio, access, fn

module.exports.destroyTwitter = (radio, name, fn) ->
  console.log "foo"
  Twitter.destroy {
    radio_id : radio.id
    name     : name }, fn

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
  }, (err, user) ->

    if err?
      return fn null, err

    fn user, null

module.exports.updateUser = (user, fn) ->
  User.update user.id, user, fn
