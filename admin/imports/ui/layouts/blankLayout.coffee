require './blankLayout.tpl.jade'

Template.blankLayout.onRendered ->

# Add gray color for background in blank layout
  $("body").addClass "gray-bg"

Template.blankLayout.destroyed = ->

# Remove special color for blank layout
  $("body").removeClass "gray-bg"