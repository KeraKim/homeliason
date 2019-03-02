require './faqs.tpl.jade'

{ saveAs } = require '/imports/api/client/FileSaver.min.js'
{ state } = require '/imports/ui/components/searchForm.coffee'
{ buildQuery } = require '/imports/ui/components/searchForm.coffee'

Template.faqs.onCreated ->
  @subscribe 'faqs'
  @visible = new ReactiveVar true
  @nonVisible = new ReactiveVar true

Template.faqs.onRendered ->
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

Template.faqs.events

  'change input[name=visible]': (e, t)->
    value = $('[name=visible]').is ':checked'
    t.visible.set value

  'change input[name=nonVisible]': (e, t)->
    value = $('[name=nonVisible]').is ':checked'
    t.nonVisible.set value

  'click #btnAdd': (e)->
    e.preventDefault()
    FlowRouter.go 'addFaq'

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
        faq = Blaze.getData(element)
        unless faq.isVisible
          Meteor.call 'faqs.update', faq._id,
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
        faq = Blaze.getData(element)
        console.log 'element', faq
        if faq.isVisible
          Meteor.call 'faqs.update', faq._id,
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
        faq = Blaze.getData(element)
        Meteor.call 'faqs.update', faq._id,
          isActive: false
      clearAllCheckbox()
      swal "결과", "삭제되었습니다.", "success"

  'click #btnExcel': (e)->
    query = buildQuery()
    rawData = []
    Faqs.find(query).map (faq) ->
      isVisible = if faq?.isVisible is false then 'X' else 'O'
      obj = {}
      obj['등록일'] = faq.createdAt
      obj['제목'] = faq.title
      obj['내용'] = faq.content
      obj['노출여부'] = isVisible
      rawData.push obj
    csv = json2csv rawData, true, true
    blob = new Blob [csv], {type: "text/plain;charset=utf-8;",}
    saveAs blob, "faqs.csv"

  'click #title' : (e ,t ) ->
    faq = Blaze.getData(e.target)
    FlowRouter.go 'editFaq', {id: faq._id}


Template.faqs.helpers
  'faqs': ->
    query = buildQuery()
    visible = Template.instance().visible.get()
    nonVisible = Template.instance().nonVisible.get()
    if visible is true and nonVisible is false
      query.isVisible = true
    if nonVisible is true and visible is false
      query.isVisible = false
    #    query = {}
    page = FlowRouter.getQueryParam 'page' or 1
    limit = 10
    options =
      limit: limit
      skip: (page - 1) * limit
      sort:
        createdAt: -1
    Faqs.find query, options

  'pageTotalCount': ->
    query = buildQuery()
    #    query = {}
    Faqs.find(query).count()

  'totalCount': ->
    Faqs.find().count()
#    Counts.get 'notices.total.counts'
  'totalVisibleCount': ->
    Faqs.find(isVisible: true).count()
#    Counts.get 'notices.total.visible.counts'


