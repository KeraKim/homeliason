require './pagination.tpl.jade'
#{ ReactiveDict } = require 'meteor/reactive-dict'

itemsPerPage = 10

Template.pagination.onCreated ->
  @state = new ReactiveDict()
  @state.set 'totalItems', 0
  @state.set 'pages', 1
  @state.set 'currentPage', 1

  @autorun =>
    totalItems = Template.currentData().pageTotalCount
    @state.set 'totalItems', totalItems
    pages = parseInt(totalItems / itemsPerPage)
    modulus = totalItems % itemsPerPage
    if modulus > 0
      pages = pages + 1

    if pages is 0 then pages = 1
#    console.log 'pages onCreated', pages
    @state.set 'pages', pages

  @autorun =>
    currentPage = FlowRouter.getQueryParam 'page'
    if currentPage?
      @state.set 'currentPage', currentPage

Template.pagination.events
  'click .page': (e)->
    e.preventDefault()
    Template.instance().state.set 'currentPage', $(e.target).text()
    FlowRouter.setQueryParams
      page: $(e.target).text()
  'click .first': (e)->
    e.preventDefault()
    FlowRouter.setQueryParams
      page: 1
  'click .previous': (e)->
    e.preventDefault()
    if Template.instance().state.get('currentPage') > 1
      FlowRouter.setQueryParams
        page: Template.instance().state.get('currentPage') - 1
  'click .next': (e)->
    e.preventDefault()
    currentPage = parseInt Template.instance().state.get('currentPage')
    if currentPage < parseInt(Template.instance().state.get('pages'))
      FlowRouter.setQueryParam
        page: currentPage + 1
  'click .last': (e)->
    e.preventDefault()
    FlowRouter.setQueryParams
      page: Template.instance().state.get('pages')

Template.pagination.helpers
  'pages': ->
    pages = parseInt Template.instance().state.get('pages')
    currentPage = parseInt Template.instance().state.get('currentPage')
    startIndex = currentPage - 4
    endIndex = currentPage + 5

#    console.log 'pages', pages
#    console.log 'currentPage', currentPage
#    console.log 'startIndex before', startIndex
#    console.log 'endIndex before', endIndex

    if pages < itemsPerPage
      startIndex = 1
      endIndex = pages
    if startIndex < 1
      startIndex = 1
      endIndex = itemsPerPage
    if endIndex > pages
      startIndex = pages - (itemsPerPage - 1)
      endIndex = pages

#    console.log 'startIndex after', startIndex
#    console.log 'endIndex after', endIndex
    [startIndex..endIndex]
  'active': (number)->
    if number is parseInt(Template.instance().state.get('currentPage'))
      'active'
    else
      null
  'showFirst': ->
    if parseInt(Template.instance().state.get('currentPage')) is 1 then false else true
  'showLast': ->
    if parseInt(Template.instance().state.get('currentPage')) is parseInt(Template.instance().state.get('pages')) then false else true
