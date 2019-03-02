require './notices.tpl.jade'

{ saveAs } = require '/imports/api/client/FileSaver.min.js'
{ state } = require '/imports/ui/components/searchForm.coffee'
{ buildQuery } = require '/imports/ui/components/searchForm.coffee'

Template.notices.onCreated ->
  @subscribe 'notices'
  @visible = new ReactiveVar true
  @nonVisible = new ReactiveVar true

Template.notices.onRendered ->

  searchIdTexts = []
  initial =
    id: 'title'
    text: '제목'
  searchIdTexts.push initial
  state.set 'searchIdTexts', searchIdTexts
  state.set 'currentSearchIdText', initial
  state.set 'startsAt', ''

clearAllCheckbox = ->
  $('input.visible-check').prop 'checked', false
  $('input.visible-check-all').prop 'checked', false

checkSelectedCheckbox = ->
  if 1 > $('tbody tr').find(":checkbox:checked").length
    swal "콘텐츠 미선택", "콘텐츠를 선택해 주세요", "error"
    false
  else
    true

Template.notices.events

  'change input[name=visible]': (e, t)->
    value = $('[name=visible]').is ':checked'
    t.visible.set value

  'change input[name=nonVisible]': (e, t)->
    value = $('[name=nonVisible]').is ':checked'
    t.nonVisible.set value

  'click #btnAdd': (e)->
    e.preventDefault()
    FlowRouter.go 'addNotice'

  'change input[name=checkAll]': (e)->
    checked = $('input[name=checkAll]').is ':checked'
    $('input.visible-check').prop 'checked', checked

  'click #btnVisible': (e)->
    unless checkSelectedCheckbox()
      return
    swal
      title: "노출상태"
      text: "콘텐츠를 노출 상태로 변경하시겠습니까?"
      type: "warning"
      showCancelButton: true
      cancelButtonText: '취소'
      confirmButtonText: "노출"
      closeOnConfirm: false
      html: false
    , ->
#    console.log $('tbody tr').find(":checkbox:checked")
      for element in $('tbody tr').find(":checkbox:checked")
        notice = Blaze.getData(element)
        unless notice.isVisible
          Meteor.call 'notices.update', notice._id,
            isVisible: true
      clearAllCheckbox()
      swal "결과", "노출상태가 변경되었습니다.", "success"

  'click #btnInvisible': (e)->
    unless checkSelectedCheckbox()
      return
    console.log 'here'
    swal
      title: "노출상태"
      text: "콘텐츠를 비노출 상태로 변경하시겠습니까?"
      type: "warning"
      showCancelButton: true
      cancelButtonText: '취소'
#      confirmButtonColor: "#DD6B55"
      confirmButtonText: "비노출"
      closeOnConfirm: false
      html: false
    , ->
      for element in $('tbody tr').find(":checkbox:checked")
        console.log 'element', element
        notice = Blaze.getData(element)
        console.log 'element', notice
        if notice.isVisible
          Meteor.call 'notices.update', notice._id,
            isVisible: false
      clearAllCheckbox()
      swal "결과", "노출상태가 변경되었습니다.", "success"

  'click #btnRemove': (e)->
    unless checkSelectedCheckbox()
      return
    swal
      title: "삭제"
      text: "콘텐츠를 삭제 하시겠습니까?"
      type: "warning"
      showCancelButton: true
      cancelButtonText: '취소'
#      confirmButtonColor: "#DD6B55"
      confirmButtonText: "삭제"
      closeOnConfirm: false
      html: false
    , ->
      for element in $('tbody tr').find(":checkbox:checked")
        notice = Blaze.getData(element)
        Meteor.call 'notices.update', notice._id,
          isActive: false
      clearAllCheckbox()
      swal "결과", "삭제되었습니다.", "success"

  'click #btnExcel': (e)->
#    rawData = Notifications.find().fetch()
#    csv = json2csv rawData, true, true
#    blob = new Blob [csv], {type: "text/plain;charset=utf-8;",}
#    saveAs blob, "notices.csv"

    query = buildQuery()
    rawData = []
    Notices.find(query).map (notice) ->
      isVisible = if notice?.isVisible is false then 'X' else 'O'
      obj = {}
      obj['등록일'] = notice.createdAt
      obj['제목'] = notice.title
      obj['공지 시작일'] = notice.startsAt
      obj['공지 종료일'] = notice.endsAt
      obj['노출여부'] = isVisible
      rawData.push obj
    csv = json2csv rawData, true, true      # package 임
    blob = new Blob [csv], {type: "text/plain;charset=utf-8;",}
    saveAs blob, "notice.csv"

  'click #title' : (e ,t ) ->
      notice = Blaze.getData(e.target)
      FlowRouter.go 'editNotice', {id: notice._id}
      console.log 'TEST'


Template.notices.helpers
  'notices': ->
    query = buildQuery()
    #    query = {}
    visible = Template.instance().visible.get()
    nonVisible = Template.instance().nonVisible.get()
    if visible is true and nonVisible is false
      query.isVisible = true
    if nonVisible is true and visible is false
      query.isVisible = false
    page = FlowRouter.getQueryParam 'page' or 1
    limit = 10
    options =
      limit: limit
      skip: (page - 1) * limit
      sort:
        createdAt: -1
    Notices.find query, options
#    Notices.find {}, options

  'pageTotalCount': ->
    query = buildQuery()
    #    query = {}
    Notices.find(query).count()

  'totalCount': ->
    Notices.find().count()
#    Counts.get 'notices.total.counts'
  'totalVisibleCount': ->
    Notices.find(isVisible: true).count()
#    Counts.get 'notices.total.visible.counts'


