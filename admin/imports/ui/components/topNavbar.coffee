require './topNavbar.tpl.jade'

Template.topNavbar.onRendered ->


# FIXED TOP NAVBAR OPTION
# Uncomment this if you want to have fixed top navbar
# $('body').addClass('fixed-nav');
# $(".navbar-static-top").removeClass('navbar-static-top').addClass('navbar-fixed-top');
Template.topNavbar.events

  'click .logout-button': (e, t) ->
    Meteor.logout()
    FlowRouter.go 'login'

# Toggle left navigation
  "click #navbar-minimalize": (event) ->
    event.preventDefault()

    # Toggle special class
    $("body").toggleClass "mini-navbar"

    # Enable smoothly hide/show menu
    if not $("body").hasClass("mini-navbar") or $("body").hasClass("body-small")

# Hide menu in order to smoothly turn on when maximize menu
      $("#side-menu").hide()

      # For smoothly turn on menu
      setTimeout (->
        $("#side-menu").fadeIn 400
      ), 200
    else if $("body").hasClass("fixed-sidebar")
      $("#side-menu").hide()
      setTimeout (->
        $("#side-menu").fadeIn 400
      ), 200
    else

# Remove all inline style from jquery fadeIn function to reset menu state
      $("#side-menu").removeAttr "style"


# Toggle right sidebar
  "click .right-sidebar-toggle": ->
    $("#right-sidebar").toggleClass "sidebar-open"

