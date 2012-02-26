_ = require "underscore"

module.exports.clean = (data) ->
  fn = (label) ->
    delete data[label] unless data[label]?
  fn label for label of data
  return data

module.exports.pls = (radio) ->
  pls = "[playlist]\r\n"
  index = 0

  _.each radio.streams, (stream) ->
    pls += "File#{++index}=#{stream.url}\r\n"
    pls += "Title#{index}=#{radio.name} - #{stream.format}\r\n"

  pls += "NumberOfEntries=#{index}\r\n"
  pls += "Version=2\r\n"

  pls
