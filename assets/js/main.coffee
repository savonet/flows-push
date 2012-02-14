#= require_tree vendor
#
#= require app
#
#= require player
#
#= require model
#= require collection
#= require_tree models
#
#= require_tree templates
#
#= require view
#= require_tree views
#
#= require page
#= require_tree pages

$ ->
  App.app    = new App
  App.player = new App.Player
