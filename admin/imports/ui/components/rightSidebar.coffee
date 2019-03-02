require './rightSidebar.tpl.jade'
require '/imports/api/client/slimscroll/jquery.slimscroll.min.js'

Template.rightSidebar.onRendered ->

# Initialize slimscroll for right sidebar
  $(".sidebar-container").slimScroll
    height: "100%"
    railOpacity: 0.4
    wheelStep: 10


  # Move right sidebar top after scroll
  $(window).scroll ->
    if $(window).scrollTop() > 0 and not $("body").hasClass("fixed-nav")
      $("#right-sidebar").addClass "sidebar-top"
    else
      $("#right-sidebar").removeClass "sidebar-top"

