require './mainLayout.tpl.jade'

require '/imports/ui/components/footer.coffee'
require '/imports/ui/components/navigation.coffee'
require '/imports/ui/components/rightSidebar.coffee'
require '/imports/ui/components/topNavbar.coffee'
require '/imports/ui/components/spinnerContainer.tpl.jade'

Template.mainLayout.onRendered ->
  # Minimalize menu when screen is less than 768px
  $(window).bind "resize load", ->
    if $(this).width() < 769
      $("body").addClass "body-small"
    else
      $("body").removeClass "body-small"


  # Fix height of layout when resize, scroll and load
  $(window).bind "load resize scroll", ->
    unless $("body").hasClass("body-small")
      navbarHeigh = $("nav.navbar-default").height()
      wrapperHeigh = $("#page-wrapper").height()
      $("#page-wrapper").css "min-height", navbarHeigh + "px"  if navbarHeigh > wrapperHeigh
      $("#page-wrapper").css "min-height", $(window).height() + "px"  if navbarHeigh < wrapperHeigh
      if $("body").hasClass("fixed-nav")
        if navbarHeigh > wrapperHeigh
          $("#page-wrapper").css "min-height", navbarHeigh - 60 + "px"
        else
          $("#page-wrapper").css "min-height", $(window).height() - 60 + "px"

  @autorun =>
    console.log 'connection: ', Meteor.status().status
    if Meteor.status().status is 'waiting'
      console.log 'connection waiting................'
      console.log Meteor.status()
    if Meteor.status().retryCount > 3
      alert '서버와의 연결이 끊어졌습니다. 나중에 다시 시도해 주세요.'
      Meteor.disconnect()



# SKIN OPTIONS
# Uncomment this if you want to have different skin option:
# Available skin: (skin-1 or skin-3, skin-2 deprecated, md-skin)
# $('body').addClass('md-skin');

# FIXED-SIDEBAR
# Uncomment this if you want to have fixed left navigation
# $('body').addClass('fixed-sidebar');
# $('.sidebar-collapse').slimScroll({
#     height: '100%',
#     railOpacity: 0.9
# });

# BOXED LAYOUT
# Uncomment this if you want to have boxed layout
# $('body').addClass('boxed-layout');