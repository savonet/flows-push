{City} = require "geoip-static"
city   = new City "./geoip/GeoIPCity.dat"

module.exports.getPosition = (ip, fn) ->
  city.lookup ip, (err, data) ->
    return fn null, err if err?
    fn {
      latitude  : data.latitude,
      longitude : data.longitude }, null

