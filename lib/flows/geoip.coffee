{City} = require "geoip-static"
city   = new City "./geoip/GeoIPCity.dat"

module.exports.getCity = (ip, fn) ->
  city.lookup ip, fn
