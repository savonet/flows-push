FastLegS = require "FastLegS-toots"

url = process.env.DATABASE_URL or "postgres://localhost/flows"
FastLegS.connect url

module.exports.Stream = Stream = FastLegS.Base.extend
  tableName  : "streams"
  primaryKey : "id"

module.exports.Listener = FastLegS.Base.extend
  tableName  : "listeners"
  primaryKey : "id"

module.exports.Twitter = Twitter = FastLegS.Base.extend
  tableName  : "twitters"
  primaryKey : "id"

module.exports.Radio = Radio = FastLegS.Base.extend
  tableName  : "radios"
  primaryKey : "id"

module.exports.TwitterRadio = TwitterRadio = FastLegS.Base.extend
  tableName   : "twitters_radios"
  foreignKeys : [ {
    model : Twitter
    key   : "twitter_id" }, {
    model : Radio
    key   : "radio_id" } ]

Radio.many = [ {
  streams : Stream,
  joinOn  : "radio_id" },{
  twitters : Twitter,
  assoc    : TwitterRadio } ]

Twitter.many = [
  radios : Radio
  assoc  : TwitterRadio ]

module.exports.User = FastLegS.Base.extend
  tableName  : "users"
  primaryKey : "id"
  many       : [
    radios  : Radio
    joinOn  : "user_id"
  ]
