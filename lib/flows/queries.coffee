{Radio} = require "schema/model"
{clean} = require "lib/flows/utils"

exportRadio = (radio) ->
  delete radio.id
  radio.streams = (clean stream for stream in radio.streams)
  clean radio

module.exports.getRadios = (param, fn) ->
  Radio.find param, {
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
  }, (err, radios) ->
  
    if err?
      return fn null, err

    radios = radios or []
    radios = (exportRadio radio for radio in radios)

    fn radios, null
