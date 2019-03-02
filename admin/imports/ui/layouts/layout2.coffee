Template.layout2.onRendered ->

# Add special class for handel top navigation layout
  $("body").addClass "top-navigation"

Template.layout2.destroyed = ->

# Remove special top navigation class
  $("body").removeClass "top-navigation"