require './userGuide.tpl.jade'

pageInit = ->

Template.userGuide.onCreated ->

  @subscribe 'terms'

Template.userGuide.onRendered ->
  pageInit()

Template.userGuide.events

Template.userGuide.helpers
  guide : ->
    guide = Terms.findOne(type : '안내 사항')
    unless guide
      return

    guide.text