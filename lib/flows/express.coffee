express        = require "express"
express.assets = require "connect-assets"

resolveProxy = (req, res, next) ->
  forwardedIpsStr = req.header "x-forwarded-for"
  if forwardedIpsStr?
    [ipAddress] = forwardedIpsStr.split ","
  ipAddress = req.connection.remoteAddress unless ipAddress?
  req.connection.remoteAddress = ipAddress
  next()

module.exports.app = app = express.createServer()

port = parseInt process.env.PORT or 6000
app.listen port, ->
  console.log "Listening on port " + app.address().port + "."

app.use resolveProxy

logFormat = ":remote-addr :method :url (:status) took :response-time ms."
app.use express.logger logFormat

app.configure "production", ->
  process.addListener "uncaughtException", (err) ->
    console.error "Uncaught exception: #{err}"

app.use express.static "public"

app.use express.assets
  buildDir       : "tmp"
  buildFilenamer : (file) -> file

app.set "view engine", "eco"

app.get "/", (req, res) ->
  res.redirect "http://liquidsoap.fm/flows.html"
