_               = require "underscore"
{app,auth,host} = require "../lib/flows/express"
queries         = require "../lib/flows/queries"
url             = require "url"
{pls}           = require "../lib/flows/utils"

app.get "/radio", (req, res) ->
  name    = req.query.name
  website = req.query.website

  params         = {}
  params.name    = name if name?
  params.website = website if website?

  queries.getRadio params, (err, radio) ->
    return res.send("An error occured while processing your request", 500) if err?

    return res.send "No such radio", 404 unless radio?

    res.header "Access-Control-Allow-Origin", "*"
    res.contentType "json"
    res.end JSON.stringify queries.exportRadio(radio)

app.get /^\/radio\/([^\/\.]+)(\.|\/)pls$/, (req, res) ->
  [token] = req.params
  queries.getRadio { token : token }, (err, radio) ->
    return res.send("An error occured while processing your request", 500) if err?

    return res.send "No such radio", 404 unless radio?

    res.header "Access-Control-Allow-Origin", "*"
    res.contentType "audio/x-scpls"
    
    res.send pls(radio)

app.get "/radio/:token", (req, res) ->
  queries.getRadio { token : req.params.token }, (err, radio) ->
    return res.send("An error occured while processing your request", 500) if err?

    return res.send "No such radio", 404 unless radio?

    res.header "Access-Control-Allow-Origin", "*"
    res.contentType "json"
    res.end JSON.stringify queries.exportRadio(radio)

app.get /^\/radio\/([^\/]+)\/(.+)$/, (req, res) ->
  [token, format] = req.params

  queries.getRadio { token : token }, (err, radio) ->
    return res.send("An error occured while processing your request", 500) if err?

    return res.send "No such radio", 404 unless radio?

    stream = _.find radio.streams, (stream) -> stream.format == format

    return res.send "No such stream", 404 unless stream?

    queries.getListener stream, req.connection.remoteAddress, (err, listener) ->
      return if err? or not listener?
      queries.updateListener listener

    res.redirect stream.url

app.get "/radios", (req, res) ->
  d = new Date()
  d.setHours(d.getHours()-1)
  queries.getRadios { "last_seen.gte" : d }, (err, ans) ->
    return res.send("An error occured while processing your request", 500) if err?

    res.header "Access-Control-Allow-Origin", "*"
    res.contentType "json"
    res.end JSON.stringify queries.exportRadios(ans)

app.get "/test", (req, res) -> res.render "test.eco"
app.get "/", (req, res) -> res.render "index.eco"
