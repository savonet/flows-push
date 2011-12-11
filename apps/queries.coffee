{app}   = require "lib/flows/express"
queries = require "lib/flows/queries"

app.get "/radio", (req, res) ->
  name    = req.query.name
  website = req.query.website
  token   = req.query.token

  params = {}
  params.token   = token if token?
  params.name    = name if name?
  params.website = website if website?

  queries.getRadios params, (ans, err) ->
    return res.send("An error occured while processing your request", 500) if err?

    return res.send "No such radio", 404 unless ans? and ans.length == 1

    res.header "Access-Control-Allow-Origin", "*"
    res.contentType "json"
    res.end JSON.stringify ans.shift()

app.get "/radios", (req, res) ->
  d = new Date()
  d.setHours(d.getHours()-1)
  queries.getRadios { "last_seen.gte" : d }, (ans, err) ->
    return res.send("An error occured while processing your request", 500) if err?

    res.header "Access-Control-Allow-Origin", "*"
    res.contentType "json"
    res.end JSON.stringify ans
