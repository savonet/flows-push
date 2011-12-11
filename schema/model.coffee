FastLegS = require "FastLegS"

url = process.env.DATABASE_URL or "postgres://localhost:7778/flows"
FastLegS.connect url

Stream = FastLegS.Base.extend
  tableName  : "streams"
  primaryKey : "id"

module.exports.Radio = FastLegS.Base.extend
  tableName  :"radios"
  primaryKey : "id"
  many       : [
    streams : Stream
    joinOn  : "radio_id"
  ]
