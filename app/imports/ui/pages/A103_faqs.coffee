require './A103_faqs.tpl.jade'

Template.A103_faqs.onCreated ->

  @subscribe 'faqs'

Template.A103_faqs.onRendered ->

Template.A103_faqs.events

  'click .accordion li' : (e, t) ->
    if $(e.currentTarget).closest('.accordion').hasClass('one-open')
      $(e.currentTarget).closest('.accordion').find('li').removeClass 'active'
      $(e.currentTarget).addClass 'active'
    else
      $(e.currentTarget).toggleClass 'active'
    if typeof window.mr_parallax != 'undefined'
      setTimeout mr_parallax.windowLoad, 500

Template.A103_faqs.helpers

  faqs : ->
    Faqs.find
      isVisible : true