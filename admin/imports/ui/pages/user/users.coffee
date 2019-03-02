require './users.tpl.jade'

{ saveAs } = require '/imports/api/client/FileSaver.min.js'
{ state } = require '/imports/ui/components/searchForm.coffee'
{ buildQuery } = require '/imports/ui/components/searchForm.coffee'

Template.users.onCreated ->
  @subscribe 'users'
  @userId = new ReactiveVar ''

Template.users.onRendered ->

  searchIdTexts = []
  initial =
    id: 'profile.name'
    text: '이름'
  searchIdTexts.push initial
  searchIdTexts.push
    id: 'emails.[0].address'
    text: '이메일'
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

Template.users.events

  'click .userBuyCount' : (e, t) ->
    userId = Blaze.getData(e.target)._id
    t.userId.set userId
    $('.buyModal').modal 'show'

  'change input[name=checkAll]': (e)->
    checked = $('input[name=checkAll]').is ':checked'
    $('input.visible-check').prop 'checked', checked

  'click #btnRemove': (e)->
    unless checkSelectedCheckbox()
      return
    swal
      title: "삭제"
      text: "회원을 탈퇴 시키시겠습니까?"
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
        Meteor.call 'user.dropout', user._id,
          isActive: false
      clearAllCheckbox()
      swal "결과", "탈퇴 되었습니다.", "success"

  'click #btnAdmin': (e)->
    unless checkSelectedCheckbox()
      return
    swal
      title: "관리자 지정"
      text: "회원에게 관리자 권한을 부여하시겠습니까?"
      type: "warning"
      showCancelButton: true
      cancelButtonText: '취소'
#      confirmButtonColor: "#DD6B55"
      confirmButtonText: "예"
      closeOnConfirm: false
      html: false
    , ->
      for element in $('tbody tr').find(":checkbox:checked")
        user = Blaze.getData(element)
        Meteor.call 'users.changeAdmin', user._id,
          'profile.isAdmin' : true
      clearAllCheckbox()
      swal "결과", "관리자 권한이 부여되었습니다.", "success"

  'click #btnNoAdmin': (e)->
    unless checkSelectedCheckbox()
      return
    swal
      title: "관리자 해제"
      text: "회원에게 관리자 권한을 해제하시겠습니까?"
      type: "warning"
      showCancelButton: true
      cancelButtonText: '취소'
#      confirmButtonColor: "#DD6B55"
      confirmButtonText: "예"
      closeOnConfirm: false
      html: false
    , ->
      for element in $('tbody tr').find(":checkbox:checked")
        user = Blaze.getData(element)
        Meteor.call 'users.changeAdmin', user._id,
          'profile.isAdmin' : false
      clearAllCheckbox()
      swal "결과", "관리자 권한이 해제되었습니다.", "success"

  'click #btnExcel': (e)->
    query = buildQuery()
    rawData = []
    Meteor.users.find(query).map (user) ->

      count = Sales.find(userId : user._id).count()
      unless  count
        count = '-'

      sales = Sales.find(userId : user._id)
      total = 0
      if sales
        sales.forEach (sale) ->
          total += sale.price
        total

      likeCount = 0
      if user.profile.likes
        likeCount = user.profile.likes.length

#      email =  user.emails[0].address

      obj = {}

      obj['가입일'] = user.createdAt
      obj['이름'] = user.profile.userName
#      obj['이메일'] = email
      obj['구매수'] = count
      obj['구매액'] = total
      obj['찜한수'] = likeCount
      obj['관리자 권한'] = if user?.profile.isAdmin is false then 'X' else 'O'

      rawData.push obj
    csv = json2csv rawData, true, true
    blob = new Blob [csv], {type: "text/plain;charset=utf-8;",}
#    console.log 'blob', csv
    saveAs blob, "users.csv"

Template.users.helpers
  users: ->
    query = buildQuery()
    page = FlowRouter.getQueryParam 'page' or 1
    limit = 10
    options =
      limit: limit
      skip: (page - 1) * limit
      sort:
        createdAt: -1
    Meteor.users.find query, options

  pageTotalCount: ->
    query = {}

    Meteor.users.find(query).count()

  status: (user)->
    if user.profile.isActive then '가입' else '탈퇴'

  dropoutDate: (user)->
    if user.profile.isActive
      '-'
    else
      makeDate user.profile.droppedOutAt

  isAdminText: (user)->
    if user.profile.isAdmin
      '관리자'
    else
      '-'

  userBuyCount : (userId) ->
    count = Sales.find(userId : userId).count()
    unless  count
      return '-'
    count

  # 해당 유저를 가지고있는 필드들의 총합
  userTotalPrice : (userId) ->
    sales = Sales.find
      userId : userId
    unless sales
      return 0
    total = 0
    sales.forEach (sale) ->
      total += sale.price
    total

  userBuy : ->
    userId = Template.instance().userId.get()
    sales = Sales.find(userId : userId)
    unless sales
      return
    sales

  dateFormat: (date)->
    moment(date).format('YYYY-MM-DD')



