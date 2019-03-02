require './events.tpl.jade'

{ saveAs } = require '/imports/api/client/FileSaver.min.js'
{ state } = require '/imports/ui/components/searchForm.coffee'
{ buildQuery } = require '/imports/ui/components/searchForm.coffee'

Template.events.onCreated ->
  @subscribe 'events'
  @designer = new ReactiveVar ''
  @visible = new ReactiveVar true
  @nonVisible = new ReactiveVar true
  @popup = new ReactiveVar true
  @nonPopup = new ReactiveVar true


Template.events.onRendered ->

  searchIdTexts = []
  initial =
    id: 'title'
    text: '이름'
  searchIdTexts.push initial
  state.set 'searchIdTexts', searchIdTexts
  state.set 'currentSearchIdText', initial
  state.set 'startsAt', ''

clearAllCheckbox = ->
  $('input.visible-check').prop 'checked', false
  $('input.visible-check-all').prop 'checked', false

checkSelectedCheckbox = ->
  if 1 > $('tbody tr').find(":checkbox:checked").length
    swal "이벤트 미선택", "이벤트를 선택해 주세요", "error"
    false
  else
    true

Template.events.events

  'change input[name=visible]': (e, t)->
    value = $('[name=visible]').is ':checked'
    t.visible.set value

  'change input[name=nonVisible]': (e, t)->
    value = $('[name=nonVisible]').is ':checked'
    t.nonVisible.set value

  'change input[name=popup]': (e, t)->
    value = $('[name=popup]').is ':checked'
    t.popup.set value

  'change input[name=nonPopup]': (e, t)->
    value = $('[name=nonPopup]').is ':checked'
    t.nonPopup.set value

  'change input[name=checkAll]': (e)->
    checked = $('input[name=checkAll]').is ':checked'
    $('input.visible-check').prop 'checked', checked

  'click #btnVisible': (e, t) ->
    unless checkSelectedCheckbox()
      return
    for element in $('tbody tr').find(":checkbox:checked")
      event = Blaze.getData(element)
      Meteor.call 'events.visible', event._id, true

  'click #btnNonVisible ': (e, t) ->
    unless checkSelectedCheckbox()
      return
    for element in $('tbody tr').find(":checkbox:checked")
      event = Blaze.getData(element)
      Meteor.call 'events.visible', event._id, false

  'click #btnPopup': (e, t) ->
    unless checkSelectedCheckbox()
      return
    for element in $('tbody tr').find(":checkbox:checked")
      event = Blaze.getData(element)
      Meteor.call 'events.popup', event._id, true

  'click #btnNonPopup': (e, t) ->
    unless checkSelectedCheckbox()
      return
    for element in $('tbody tr').find(":checkbox:checked")
      event = Blaze.getData(element)
      Meteor.call 'events.popup', event._id, false

  'click #btnRemove': (e)->
    unless checkSelectedCheckbox()
      return
    swal
      title: "삭제"
      text: "이벤트를 삭제하시키시겠습니까?"
      type: "warning"
      showCancelButton: true
      cancelButtonText: '취소'
#      confirmButtonColor: "#DD6B55"
      confirmButtonText: "삭제"
      closeOnConfirm: false
      html: false
    , ->
      for element in $('tbody tr').find(":checkbox:checked")
        event = Blaze.getData(element)
        Meteor.call 'events.remove', event._id
      clearAllCheckbox()
      swal "결과", "삭제 되었습니다.", "success"

  'click #btnExcel': (e)->
    query = buildQuery()
    rawData = []
    Event.find(query).map (event) ->

      startsAt = event.startsAt
      endsAt = ''
      if event.isEndless
        endsAt = '무제한'
      else
        endsAt = event.endsAt

      obj = {}
      obj['노출상태'] = if event.isVisible is false then 'X' else 'O'
      obj['팝업설정'] = if event.isPopup is false then 'X' else 'O'
      obj['등록/수정일'] = event.updatedAt
      obj['제목'] = event.title
      obj['노출기간'] = startsAt.concat(endsAt)
      rawData.push obj
    csv = json2csv rawData, true, true
    blob = new Blob [csv], {type: "text/plain;charset=utf-8;",}
    #    console.log 'blob', csv
    saveAs blob, "event.csv"

  'click #eventName' : (e, t) ->
    event = Blaze.getData(e.currentTarget)
    FlowRouter.go 'editEvents', {id : event._id}

  'click #btnAdd' : (e, t) ->
    FlowRouter.go 'addEvents'

Template.events.helpers
  events: ->
    query = buildQuery()
    visible = Template.instance().visible.get()
    nonVisible = Template.instance().nonVisible.get()
    popup = Template.instance().popup.get()
    nonPopup = Template.instance().nonPopup.get()
    if visible is true and nonVisible is false
      query.isVisible = true
    if nonVisible is true and visible is false
      query.isVisible = false
    if popup is true and nonPopup is false
      query.isPopup = true
    if nonPopup is true and popup is false
      query.isPopup = false
    page = FlowRouter.getQueryParam 'page' or 1
    limit = 10
    options =
      limit: limit
      skip: (page - 1) * limit
      sort:
        createdAt: -1
    Events.find query, options

  pageTotalCount: ->
    query = {}
    Events.find(query).count()

  status: (status)->
    if status then 'O' else 'X'

  dateFormat: (date)->
    if date is '-'
      '-'
    else
      moment(date).format('YYYY-MM-DD')


