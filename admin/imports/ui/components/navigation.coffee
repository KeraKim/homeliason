require './navigation.tpl.jade'
require '/imports/api/client/metisMenu/jquery.metisMenu.js'

{ FlowRouter } = require 'meteor/kadira:flow-router'

Template.navigation.onRendered ->

# Initialize metisMenu

  @autorun =>
    Tracker.afterFlush =>
      Meteor.setTimeout ->
        $("#side-menu").metisMenu()
      , 500
#  $("#side-menu").metisMenu()


# Used only on OffCanvas layout
Template.navigation.events
  "click .close-canvas-menu": ->
    $("body").toggleClass "mini-navbar"

  "click #goContests": (e)->
#    alert 'here'
    FlowRouter.go 'contests'
