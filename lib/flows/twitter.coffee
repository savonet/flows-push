{OAuth} = require "oauth"
twitter = require "ntwitter"

module.exports.clients = clients = {}

getClient = (opts, fn) ->
  return fn clients[opts.name] if clients[opts.name]?

  client = new twitter
    consumer_key        : process.env.TWITTER_CONSUMER_KEY
    consumer_secret     : process.env.TWITTER_CONSUMER_SECRET
    access_token_key    : opts.token
    access_token_secret : opts.secret

  client.verifyCredentials (err, data) ->
    if err?
      console.log "Twitter authentication error: #{err} (account: #{opts.name})"
      fn null
    else
      console.log "Twitter authentication OK! (account: #{opts.name})"
      clients[opts.name] = client
      fn client

module.exports.updateStatus = (opts, status) ->
  getClient opts, (client) ->
    return unless client?
 
    client.updateStatus status, (err, data) ->
      if err?
        console.error "Error while updating twitter status for client #{twitter.name}: #{err}"

module.exports.getRequest = (callback, fn) ->
  oa = new OAuth "https://api.twitter.com/oauth/request_token",
                 "https://api.twitter.com/oauth/access_token",
                 process.env.TWITTER_CONSUMER_KEY,
                 process.env.TWITTER_CONSUMER_SECRET,
                 "1.0",
                 callback,
                 "HMAC-SHA1"

  oa.getOAuthRequestToken (error, oauth_token, oauth_token_secret, results) ->
    return fn error, null if error?

    fn null,
      oa     : oa
      token  : oauth_token
      secret : oauth_token_secret
      url    : "https://api.twitter.com/oauth/authenticate?oauth_token=#{oauth_token}"

module.exports.getAccess = (request, verifier, fn) ->
  request.oa.getOAuthAccessToken request.token, request.secret, verifier, (error, oauth_access_token, oauth_access_token_secret, results) ->
    return fn error, null if error?

    fn null,
      name   : results.screen_name
      token  : oauth_access_token
      secret : oauth_access_token_secret
