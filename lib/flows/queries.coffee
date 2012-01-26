_                  = require "underscore"
{Listener, Radio, 
 Stream, Twitter, 
 TwittersRadios,
 User}             = require "../../schema/model"
{clean}            = require "./utils"
{getCity}          = require "./geoip"

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
      only : [ "id", "name", "token", "secret" ]
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
        fn result, null

module.exports.getListener = (stream, ip, fn) ->
  Listener.findOne { 
    stream_id : stream.id,
    ip        : ip }, (err, listener) ->
      return fn err, null if err?
      return fn null, listener if listener?
      createListener stream, ip, fn

module.exports.updateListener = (listener) ->
  Listener.update { id : listener.id }, { last_seen : new Date() }, ->

createTwitter = (radio, access, fn) ->
  Twitter.create {
    name     : access.name
    token    : access.token
    secret   : access.secret }, fn

assocTwitter = (radio, twitter, fn) ->
  ok = twitter.radios? and _.any twitter.radios, (e) -> e.token == radio.token
  return fn twitter, null if ok

  TwittersRadios.create {
    twitter_id : twitter.id
    radio_id   : radio.id }, (err, result) ->
      return fn err, null if err?
      fn null, twitter

module.exports.updateTwitter = (radio, access, fn) ->
  Twitter.findOne { name: access.name }, {
    include : {
      radios : { only : ["token"] } 
    } }, (err, twitter) ->
    return fn err, null if err?

    if twitter?
      Twitter.update { id : twitter.id }, {
        token  : access.token
        secret : access.secret }, (err, result) ->
        return fn err, null if err?
        assocTwitter radio, twitter, fn
    else
      createTwitter radio, access, (err, result) ->
        return fn err, null if err?
        [twitter] = result.rows
        assocTwitter radio, twitter, fn

module.exports.destroyRadioTwitter = (radio, twitter, fn) ->
  TwittersRadios.destroy { 
    twitter_id : twitter.id,
    radio_id   : radio.id }, fn

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
