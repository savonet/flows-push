#= require vendor/backbone.modelbinding.js
#= require sound
#
#= require app
#
#= require router
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

App.router = new App.Router

$ ->
  App.app = new App
