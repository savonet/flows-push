FastLegS = require "FastLegS-toots"

url = process.env.DATABASE_URL or "postgres://localhost/flows"
FastLegS.connect url

module.exports.Stream = Stream = FastLegS.Base.extend
  tableName  : "streams"
  primaryKey : "id"

module.exports.Listener = FastLegS.Base.extend
  tableName  : "listeners"
  primaryKey : "id"

module.exports.TwittersRadios = TwittersRadios = FastLegS.Base.extend
  tableName : "twitters_radios"

module.exports.Twitter = Twitter = FastLegS.Base.extend
  tableName  : "twitters"
  primaryKey : "id"

module.exports.Radio = Radio = FastLegS.Base.extend
  tableName  : "radios"
  primaryKey : "id"
  many       : [ {
    streams : Stream,
    joinOn  : "radio_id" },{
    twitters : Twitter,
    assoc :
      model  : TwittersRadios
      key    : "twitter_id"
      joinOn : "radio_id"
    } ]

Twitter.many = [
  radios : Radio
  assoc  :
    model  : TwittersRadios
    key    : "radio_id"
    joinOn : "twitter_id"
  ]

module.exports.User = FastLegS.Base.extend
  tableName  : "users"
  primaryKey : "id"
  many       : [
    radios  : Radio
    joinOn  : "user_id"
  ]
