class App.Page.Actions extends App.Page
  target:   ".actions div.content"
  template: "actions"

  events:
    "click   a.sort-latest":       "orderLatest"
    "click   a.sort-alphabetical": "orderAlphabetical"
    "keydown input.search":        "onDelayedSearch"
    "click   a.reset":             "onReset"
 
  asyncSearch: null

  onDelayedSearch: (e) =>
    return if @asyncSearch?

    cb = =>
      @collection.searchAny @$("input.search").val()
      @asyncSearch = null

    @asyncSearch = setTimeout cb, 200

  onReset: (e) =>
    e.preventDefault()
    @$("input.search").val ""
    @collection.search -> true

  orderAlphabetical: (e) =>
    e.preventDefault()
    @collection.sort {}, "name"

  orderLatest: (e) =>
    e.preventDefault()
    @collection.sort {}, "last_seen"
