Bitly = require "bitly"

bitly = new Bitly process.env.BITLY_USER, process.env.BITLY_KEY

module.exports = (url, fn) ->
  bitly.shorten url, (err, res) ->
    return fn err, null if err?
    return fn new Error "Http status: #{res.status_code}", null unless res.status_code == 200

    fn null, res.data.url

