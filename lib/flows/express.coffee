_              = require "underscore"
eco            = require "eco"
express        = require "express"
{createServer} = require "http"

Snockets       = require "snockets"
Snockets.compilers.eco =
  match: /\.eco$/
  compileSync: (sourcePath, source) ->
    basename = path.basename sourcePath, ".eco"
    "(function(){App.Template[\"#{basename}\"] = #{eco.precompile source}}).call(this);"

express.assets = require "connect-assets"
path           = require "path"
queries        = require "./queries"

module.exports.host = process.env.FLOWS_HOST || "http://flows.liquidsoap.fm"

resolveProxy = (req, res, next) ->
  forwardedIpsStr = req.header "x-forwarded-for"
  if forwardedIpsStr?
    [ipAddress] = forwardedIpsStr.split ","
  ipAddress = req.connection.remoteAddress unless ipAddress?
  req.connection.remoteAddress = ipAddress
  next()

module.exports.app = app = express()

app.configure "production", ->
  process.addListener "uncaughtException", (err) ->
    console.error "Uncaught exception: #{err}"

module.exports.server = server = createServer app

port = parseInt process.env.PORT or 8080
server.listen port
console.log "Listening on port #{port}."

app.use resolveProxy

logFormat = ":remote-addr :method :url (:status) took :response-time ms."
app.use express.logger logFormat

app.use express.cookieParser()
app.use express.session
  secret: process.env.FLOWS_SESSION_SECRET || "skjghskdjfhbqigohqdiouk"

app.use express.static "public"

options =
  buildDir       : "tmp"

if process.env.NODE_ENV != "production"
  options = _.extend options,
    build          : false
    buildDir       : "tmp"
    buildFilenamer : (file) -> file

app.use express.assets options

app.engine "eco", require("consolidate").eco

module.exports.auth = (req, res, next) ->
  onFailed = ->
    res.header "WWW-Authenticate", "Basic realm=\"Admin Area\""
    if req.headers.authorization?
      fn = -> res.send "Authentication required", 401
      setTimeout fn, 5000
    else
      res.send "Authentication required", 401

  return onFailed() unless req.headers.authorization? and req.headers.authorization.search("Basic ") == 0

  [user, password] = new Buffer(req.headers.authorization.split(" ")[1], "base64").toString().split ":"
  return res.send "Default user not allowed to sign-in", 400 if user == "default"

  params =
    username : user
    password : crypto.createHash("sha224").update(password).digest(encoding="hex")

  queries.getUser params, (err, user) ->
    if err? or not user?
      return onFailed()

    user.last_seen = new Date()
    user.last_ip   = req.connection.remoteAddress

    queries.updateUser user, (err) ->
      console.error "Update user failed: #{err}" if err?
      req.user = user
      return next()
