{Radio} = require "schema/model"

clean = (data) ->
  fn = (label) ->
    delete data[label] unless data[label]?
  fn label for label of data
  delete data.radio_id
  return data

exportRadio = (radio) ->
  delete radio.user_id
  radio.streams = (clean stream for stream in radio.streams)
  clean radio

module.exports.getRadios = (param, fn) ->
  Radio.find param, { 
    order   : [ "name" ],
    only    : [ "name", "token", "title", "artist", "genre", "description", "longitude", "latitude" ]
    include : { 
      streams : only : [ "format", "url", "msg" ]
    }
  }, (err, radios) ->
  
    if err?
      return fn null, err

    radios = radios or []
    radios = (exportRadio radio for radio in radios)

    fn radios, null
