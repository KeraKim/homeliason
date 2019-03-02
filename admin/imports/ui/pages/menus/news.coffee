require './news.tpl.jade'

{ saveAs } = require '/imports/api/client/FileSaver.min.js'
{ state } = require '/imports/ui/components/searchForm.coffee'
{ buildQuery } = require '/imports/ui/components/searchForm.coffee'


Template.news.onCreated ->
#  designerId = ''
#  if Meteor.user().profile.isManager
#    designerId = Meteor.user().profile.designerId
#    console.log designerId
#  else
#    designerId = Meteor.userId()
#
#  console.log '디자이너 아이디 : ', designerId
#  @subscribe 'notification', designerId
  @designerId = new ReactiveVar ''

Template.news.onRendered ->

  @autorun =>
    unless Meteor.user()
      return
    if Meteor.user().profile.isManager
      @designerId.set Meteor.user().profile.designerId
    else
      @designerId.set Meteor.userId()
    @subscribe 'notification', @designerId.get()

Template.news.events

  'click .newsTitle': (e, t) ->
    news = Blaze.getData(e.target)

    Meteor.call 'news.read', news._id,  (error, result)->
      if error
        console.log error
      else
        console.log result

    switch news.type
      when 'qna' then FlowRouter.go 'designerQnas'
      when 'adjustments' then FlowRouter.go 'designerAdjustments'
      when 'sales' then FlowRouter.go 'sales'

Template.news.helpers

  news: ->
    query =
      userId : Template.instance().designerId.get()
    #    query = {}
    page = FlowRouter.getQueryParam 'page' or 1
    limit = 10
    options =
      limit: limit
      skip: (page - 1) * limit
      sort:
        createdAt: -1

    Notification.find query, options

  pageTotalCount: ->
    query =
      userId : Template.instance().designerId.get()
    #    query = {}
    Notification.find(query).count()

  totalCount: ->
    Notices.find().count()
