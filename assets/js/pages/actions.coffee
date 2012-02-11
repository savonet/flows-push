class App.Page.Actions extends App.Page
  target:   ".actions div.content"
  template: "actions"

  events:
    "click a.sort-latest":       "orderLatest"
    "click a.sort-alphabetical": "orderAlphabetical"

  orderAlphabetical: (e) =>
    e.preventDefault()
    @collection.sort {}, "name"

  orderLatest: (e) =>
    e.preventDefault()
    @collection.sort {}, "last_seen"
