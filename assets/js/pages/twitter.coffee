class App.Page.Twitter extends App.Page
  id: "twitter-widget"

  populate: =>
    $(".twitter").html @el

    @widget = new TWTR.Widget
      id:       "twitter-widget"
      version:  2
      type:     "search"
      search:   "liquidsoap OR savonet"
      interval: 6000,
      title:    "Liquidsoap"
      subject:  "Liquidsoap in the news.."
      width:    "auto"
      height:   260
      theme:
        shell:
          background: "#990066"
          color:      "#ffffff"
        tweets:
          background: "#ffffff"
          color:      "#444444"
          links:      "#1985b5"
      features:
        scrollbar: false
        loop:      true
        live:      true
        hashtags:  true
        timestamp: true
        avatars:   true
        toptweets: true
        behavior:  "default"
    
    @widget.render().start()

