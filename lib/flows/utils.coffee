module.exports.clean = (data) ->
  fn = (label) ->
    delete data[label] unless data[label]?
  fn label for label of data
  return data
