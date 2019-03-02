require './tags.tpl.jade'

{ saveAs } = require '/imports/api/client/FileSaver.min.js'
{ state } = require '/imports/ui/components/searchForm.coffee'
{ buildQuery } = require '/imports/ui/components/searchForm.coffee'

Template.tags.onCreated ->
  @subscribe 'tags'
  @designer = new ReactiveVar ''
  @visible = new ReactiveVar true
  @nonVisible = new ReactiveVar true
  @recommend = new ReactiveVar true
  @nonRecommend = new ReactiveVar true

Template.tags.onRendered ->

  searchIdTexts = []
  initial =
    id: 'tagName'
    text: '태그명'
  searchIdTexts.push initial
  state.set 'searchIdTexts', searchIdTexts
  state.set 'currentSearchIdText', initial
  state.set 'startsAt', ''

clearAllCheckbox = ->
  $('input.visible-check').prop 'checked', false
  $('input.visible-check-all').prop 'checked', false

checkSelectedCheckbox = ->
  if 1 > $('tbody tr').find(":checkbox:checked").length
    swal "태그 미선택", "태그를 선택해 주세요", "error"
    false
  else
    true

Template.tags.events

  'change input[name=visible]': (e, t)->
    value = $('[name=visible]').is ':checked'
    t.visible.set value

  'change input[name=nonVisible]': (e, t)->
    value = $('[name=nonVisible]').is ':checked'
    t.nonVisible.set value

  'change input[name=recommend]': (e, t)->
    value = $('[name=recommend]').is ':checked'
    t.recommend.set value

  'change input[name=nonRecommend]': (e, t)->
    value = $('[name=nonRecommend]').is ':checked'
    t.nonRecommend.set value

  'change input[name=checkAll]': (e)->
    checked = $('input[name=checkAll]').is ':checked'
    $('input.visible-check').prop 'checked', checked

  'click #btnVisible': (e, t) ->
    unless checkSelectedCheckbox()
      return
    for element in $('tbody tr').find(":checkbox:checked")
      tag = Blaze.getData(element)
      Meteor.call 'tags.visible', tag._id, true

  'click #btnNonVisible ': (e, t) ->
    unless checkSelectedCheckbox()
      return
    for element in $('tbody tr').find(":checkbox:checked")
      tag = Blaze.getData(element)
      Meteor.call 'tags.visible', tag._id, false

  'click #btnRecommend': (e, t) ->
    unless checkSelectedCheckbox()
      return
    for element in $('tbody tr').find(":checkbox:checked")
      tag = Blaze.getData(element)
      Meteor.call 'tags.recommend', tag._id, true

  'click #btnNonRecommend': (e, t) ->
    unless checkSelectedCheckbox()
      return
    for element in $('tbody tr').find(":checkbox:checked")
      tag = Blaze.getData(element)
      Meteor.call 'tags.recommend', tag._id, false

  'click #btnRemove': (e)->
    unless checkSelectedCheckbox()
      return
    swal
      title: "삭제"
      text: "태그를 삭제하시키시겠습니까?"
      type: "warning"
      showCancelButton: true
      cancelButtonText: '취소'
#      confirmButtonColor: "#DD6B55"
      confirmButtonText: "삭제"
      closeOnConfirm: false
      html: false
    , ->
      for element in $('tbody tr').find(":checkbox:checked")
        tag = Blaze.getData(element)
        Meteor.call 'tags.remove', tag._id
      clearAllCheckbox()
      swal "결과", "삭제 되었습니다.", "success"

  'click #btnExcel': (e)->
    query = buildQuery()
    rawData = []
    Tags.find(query).map (tag) ->

      obj = {}
      obj['노출상태'] = if tag.isVisible is false then 'X' else 'O'
      obj['추천여부'] = if tag.isRecommend is false then 'X' else 'O'
      obj['태그명'] = tag.tagName
      obj['등록개수'] = tag.registerCount
      obj['클릭수'] = tag.clickCount
      obj['평점'] = tag.score / tag.reviewCount
      rawData.push obj
    csv = json2csv rawData, true, true
    blob = new Blob [csv], {type: "text/plain;charset=utf-8;",}
    #    console.log 'blob', csv
    saveAs blob, "tag.csv"

Template.tags.helpers
  tags: ->
    query = buildQuery()
    visible = Template.instance().visible.get()
    nonVisible = Template.instance().nonVisible.get()
    recommend = Template.instance().recommend.get()
    nonRecommend = Template.instance().nonRecommend.get()
    if visible is true and nonVisible is false
      query.isVisible = true
    if nonVisible is true and visible is false
      query.isVisible = false
    if recommend is true and nonRecommend is false
      query.isRecommend = true
    if nonRecommend is true and recommend is false
      query.isRecommend = false
    page = FlowRouter.getQueryParam 'page' or 1
    limit = 10
    options =
      limit: limit
      skip: (page - 1) * limit
      sort:
        createdAt: -1
    Tags.find query, options

  pageTotalCount: ->
    query = {}
    Tags.find(query).count()

  status: (status)->
    if status then 'O' else 'X'

  avgScore: (tag)->
    unless tag.score
      return '0'

    avg = tag.score/tag.reviewCount
    Math.round(avg)



