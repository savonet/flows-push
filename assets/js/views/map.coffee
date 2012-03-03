class App.View.Map extends App.View
  attributes:
    style: "width: 100%; height: 250px;"
  
  initialize: ->
    @infowindow = new google.maps.InfoWindow
      disableAutoPan: true
      content:        "Content..."

    latlng = new google.maps.LatLng 48.86, 2.33
    @map = new google.maps.Map @el,
      zoom:              1
      center:            new google.maps.LatLng 30.86, 2.33
      mapTypeId:         google.maps.MapTypeId.ROADMAP
      streetViewControl: false
      mapTypeControl:    false

    @collection.bind "add",   @render
    @collection.bind "reset", @render

  markers: []

  render: ->
    @collection.each (r) =>
      if marker = _.find(@markers, (x) -> x.id == r.id)
        return marker.setMap @map
      
      marker = new google.maps.Marker
        position: new google.maps.LatLng r.get("latitude"), r.get("longitude")
        map:      @map
        title:    r.get "name"
        content:  App.Template["map-content"](r)
      
      marker.id = r.id

      @markers.push marker

      infowindow = @infowindow

      google.maps.event.addListener marker, "click", ->
        infowindow.setContent @content
        infowindow.open       @map, this
 
    _.each _.filter(@markers, (m) => not @collection.any((r) -> r.id == m.id)), (m) ->
      m.setMap null

    this

