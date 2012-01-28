_          = require "underscore"
{app,host} = require "../lib/flows/express"
queries    = require "../lib/flows/queries"
twitter    = require "../lib/flows/twitter"
url        = require "url"

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

app.get "/radio/:token", (req, res) ->
  queries.getRadio { token : req.params.token }, (err, radio) ->
    return res.send("An error occured while processing your request", 500) if err?

    return res.send "No such radio", 404 unless radio?

    res.header "Access-Control-Allow-Origin", "*"
    res.contentType "json"
    res.end JSON.stringify queries.exportRadio(radio)

# Twitter part. Cannot move to a seperate module because order matters
# here with the /radios/:token/:stream endpoint..

twitterCallback = (token) -> "/radio/#{token}/twitter/confirm"

app.get "/radio/:token/twitter/auth", (req, res) ->
  queries.getRadio { token : req.params.token }, (err, radio) ->
    return res.send("An error occured while processing your request", 500) if err?

    return res.send "No such radio", 404 unless radio?

    twitter.getRequest "#{host}#{twitterCallback radio.token}", (err, request) ->
      return res.send("An error occured while processing your request", 500) if err?
      req.session.twitterRequest = request
      req.session.radio          = radio
      req.session.redirect       = req.param("redirect_to")

      res.header "Access-Control-Allow-Origin", "*"
      res.contentType "json"
      res.end JSON.stringify(url: request.url)

app.get twitterCallback(":token"), (req, res) ->
  return res.send("Invalid request", 403) unless req.session.twitterRequest? and req.param('oauth_verifier')?

  twitter.getAccess req.session.twitterRequest, req.param("oauth_verifier"), (err, access) ->
    return res.send("Authentication failed!", 401) if err?

    queries.updateTwitter req.session.radio, access, (err, result) ->
      return res.send("An error occured while processing your request", 500) if err?

      if req.session.redirect
         redirect = url.parse req.session.redirect
         if redirect.search? and redirect.search != ""
           redirect.search = "#{redirect.search}&flows_registered_twitter=#{access.name}"
         else
           redirect.search = "?flows_registered_twitter=#{access.name}"
         return res.redirect url.format(redirect)

      res.end access.name


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
