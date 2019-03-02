require './managers.tpl.jade'

{ saveAs } = require '/imports/api/client/FileSaver.min.js'
{ state } = require '/imports/ui/components/searchForm.coffee'
{ buildQuery } = require '/imports/ui/components/searchForm.coffee'

Template.managers.onCreated ->
  @userId = new ReactiveVar ''
  @designerId = new ReactiveVar ''

Template.managers.onRendered ->
  @autorun =>
    unless Meteor.user()
      return
    if Meteor.user().profile.isManager
      @designerId.set Meteor.user().profile.designerId
      @subscribe 'managers', @designerId.get()
    else
      @designerId.set Meteor.userId()
      @subscribe 'managers', Meteor.userId()

  searchIdTexts = []
  initial =
    id: 'profile.userName'
    text: '이름'
  searchIdTexts.push initial
  searchIdTexts.push
    id: 'profile.mobile'
    text: '휴대전화'
  state.set 'searchIdTexts', searchIdTexts
  state.set 'currentSearchIdText', initial
  state.set 'startsAt', ''

clearAllCheckbox = ->
  $('input.visible-check').prop 'checked', false
  $('input.visible-check-all').prop 'checked', false

checkSelectedCheckbox = ->
  if 1 > $('tbody tr').find(":checkbox:checked").length
    swal "담당자 미선택", "담당자를 선택해 주세요", "error"
    false
  else
    true

Template.managers.events

  'change input[name=checkAll]': (e)->
    checked = $('input[name=checkAll]').is ':checked'
    $('input.visible-check').prop 'checked', checked

  'click #btnRemove': (e)->
    unless checkSelectedCheckbox()
      return
    swal
      title: "삭제"
      text: "담당자를 삭제 시키시겠습니까?"
      type: "warning"
      showCancelButton: true
      cancelButtonText: '취소'
#      confirmButtonColor: "#DD6B55"
      confirmButtonText: "삭제"
      closeOnConfirm: false
      html: false
    , ->
      for element in $('tbody tr').find(":checkbox:checked")
        user = Blaze.getData(element)
        Meteor.call 'user.dropout', user._id, (error, result) ->
          if error
            console.log error
          else
            console.log result
      clearAllCheckbox()
      swal "결과", "삭제 되었습니다.", "success"

  'click #btnEditManager' : (e, t) ->
    FlowRouter.go 'addManager'

  'click #btnExcel': (e)->
    query = buildQuery()
    rawData = []
    Meteor.users.find(query).map (manager) ->

      firstMobileNumber = designer.profile.firstMobileNumber
      meddleMobileNumber = designer.profile.meddleMobileNumber
      lastMobileNumber = designer.profile.lastMobileNumber

      obj = {}
      obj['지정일'] = manager.profile.createdAt
      obj['이름'] = notice.profile.userName
#      obj['이메일'] = notice.startsAt
      obj['휴대전화'] = firstMobileNumber.concat('-',meddleMobileNumber,'-',lastMobileNumber)
      rawData.push obj
    csv = json2csv rawData, true, true
    blob = new Blob [csv], {type: "text/plain;charset=utf-8;",}
    #    console.log 'blob', csv
    saveAs blob, "users.csv"

Template.managers.helpers
  users: ->
    query = buildQuery()
    page = FlowRouter.getQueryParam 'page' or 1
    limit = 10
    options =
      limit: limit
      skip: (page - 1) * limit
      sort:
        createdAt: -1
    users = Meteor.users.find query, options
    users.forEach (user) ->
      console.log user
    users

  pageTotalCount: ->
    query = {}

    Meteor.users.find(query).count()


  makeDate: (date)->
    moment(date).format('YYYY-MM-DD')



