require './searchForm.tpl.jade'
require '/imports/api/client/datapicker/bootstrap-datepicker.js'
#require 'meteor/smartlink:datetime-format'

state = new ReactiveDict()
state.setDefault
  searchText: ''
  currentSearchIdText: {}
#  startsAt: moment().subtract(1, 'weeks').format('YYYY-MM-DD')
  startsAt: ''
  endsAt: moment().format('YYYY-MM-DD')
  durations: 'all'
  searchIdTexts: []
# {id: 'id', text: 'text'}

Template.searchForm.onRendered ->
## Initialize datapicker
  $("#datepicker .input-daterange").datepicker(
    keyboardNavigation: false
    forceParse: false
    autoclose: true
  ).on 'changeDate', (e)->
    state.set 'startsAt', $('#startsAt').val()
    state.set 'endsAt', $('#endsAt').val()

  #  $("#startsAt").datepicker(
  #    keyboardNavigation: false
  #    forceParse: false
  #    autoclose: true
  #  ).on 'changeDate', (e)->
  #    state.set 'startsAt', $('#startsAt').val()
  #    state.set 'endsAt', $('#endsAt').val()
  #
  #  $("#endsAt").datepicker(
  #    keyboardNavigation: false
  #    forceParse: false
  #    autoclose: true
  #  ).on 'changeDate', (e)->
  #    state.set 'startsAt', $('#startsAt').val()
  #    state.set 'endsAt', $('#endsAt').val()

  @autorun =>
    $("#startsAt").datepicker 'setDate', state.get('startsAt')
  @autorun =>
    $("#endsAt").datepicker 'setDate', state.get('endsAt')


Template.searchForm.events
  'click .searchField': (e)->
    e.preventDefault()
    state.set 'currentSearchIdText',
      id: e.currentTarget.id
      text: e.currentTarget.text

  'change input[name=checkAll]': (e)->
    checked = $('input[name=checkAll]').is ':checked'
    $('input.visible-check').prop 'checked', checked

  'click #btnSearch': (e)->
    state.set 'searchText', $('#searchText').val()

  'change input[name=durations]': (e)->
    value = $('[name=durations]:checked').val()
    state.set 'durations', value
    state.set 'endsAt', moment().format('YYYY-MM-DD')
    switch value
      when 'today' then state.set 'startsAt', moment().format('YYYY-MM-DD')
      when 'week' then state.set 'startsAt', moment().subtract(1, 'weeks').format('YYYY-MM-DD')
      when 'month' then state.set 'startsAt', moment().subtract(1, 'months').format('YYYY-MM-DD')
      when '3months' then state.set 'startsAt', moment().subtract(3, 'months').format('YYYY-MM-DD')
      when 'all' then state.set 'startsAt', ''

buildQuery = ->
#  query =
#    isActive: true
  query = {}

  startsAt = state.get 'startsAt'
  endsAt = state.get 'endsAt'
  #  query.updatedAt =

  if startsAt isnt ''
    query.createdAt =
      $gte: moment(startsAt).toDate()
      $lt: moment(endsAt).endOf('day').toDate()

  currentSearchIdText = state.get 'currentSearchIdText'
  #  console.log 'currentSearchIdText', currentSearchIdText
  searchText = state.get 'searchText'

  unless _.isEmpty(currentSearchIdText)
    if searchText isnt ''
      obj =
        $regex: searchText
      query[currentSearchIdText.id] = obj

  #  console.log 'buildQuery query: ', query
  return query

Template.searchForm.helpers
  'state': (key)->
    state.get key
  'currentSearchIdText': ->
    state.get('currentSearchIdText').text

exports.state = state
exports.buildQuery = buildQuery