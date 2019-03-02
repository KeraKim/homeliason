require './A102_notices.tpl.jade'

Template.A102_notices.onCreated ->

  @subscribe 'notices'

Template.A102_notices.onRendered ->

Template.A102_notices.events

  'click .accordion li' : (e, t) ->
    if $(e.currentTarget).closest('.accordion').hasClass('one-open')
      $(e.currentTarget).closest('.accordion').find('li').removeClass 'active'
      $(e.currentTarget).addClass 'active'
    else
      $(e.currentTarget).toggleClass 'active'
    if typeof window.mr_parallax != 'undefined'
      setTimeout mr_parallax.windowLoad, 500

Template.A102_notices.helpers

  notices : ->
    Notices.find()