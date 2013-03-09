FastLegS = require "FastLegS-toots"

url = process.env.DATABASE_URL or "postgres://localhost/flows"
FastLegS.connect url

module.exports.Stream = Stream = FastLegS.Base.extend
  tableName  : "streams"
  primaryKey : "id"

module.exports.Listener = FastLegS.Base.extend
  tableName  : "listeners"
  primaryKey : "id"

module.exports.Radio = Radio = FastLegS.Base.extend
  tableName  : "radios"
  primaryKey : "id"

Radio.many = [ {
  streams : Stream,
  joinOn  : "radio_id" 
} ]

module.exports.User = FastLegS.Base.extend
  tableName  : "users"
  primaryKey : "id"
  many       : [
    radios  : Radio
    joinOn  : "user_id"
  ]
