class App.Page.Actions extends App.Page
  target:   ".actions div.content"
  template: "actions"

  events:
    "click  a.sort-latest":       "orderLatest"
    "click  a.sort-alphabetical": "orderAlphabetical"
    "change input.search":        "onSearch"
    "click  a.search":            "onSearch"
    "click  a.reset":             "onReset"

  onSearch: (e) =>
    e.preventDefault()
    @collection.searchAny @$("input.search").val()

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
