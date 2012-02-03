class App.View.Twitter extends App.View
  id: "twitter-widget"

  render: =>
    @twitter = new TWTR.Widget
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
    
    @twitter.render().start()

