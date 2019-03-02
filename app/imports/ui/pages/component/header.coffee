{ bucket } = require '/imports/ui/pages/bucket.coffee'
require './header.tpl.jade'

Template.header.events
  'click a' : (e, t) ->
    e.preventDefault();
    name = $(e.currentTarget).attr('name')
    if name is 'index'
      document.body.scrollTop = 0
    bucket.set 'headerClickClass', name
    if name is 'adminPage'
      window.open('http://www.home-liaison.com:3000/login')
#      window.open('http://localhost:3120/login')
    else
      FlowRouter.go $(e.currentTarget).attr('name')

  'click .menu li': (e, t) ->
#    if !e
#      e = window.event
#    e.stopPropagation()
    if $(this).find('ul').length
      $(this).toggleClass 'toggle-sub'
    else
      $(this).parents('.toggle-sub').removeClass 'toggle-sub'



#  'click .admin-button': (e, t) ->
#    e.preventDefault()
#    window.open('http://52.78.179.150:3000')

  'click .logout' : (e, t) ->
    Meteor.logout()
    FlowRouter.go 'index'

Template.header.helpers

  isOnClass : (text) ->
    if text is bucket.get 'headerClickClass'
      'nav-on'
    else
      ''


