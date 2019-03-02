require './portfolios.tpl.jade'

{ saveAs } = require '/imports/api/client/FileSaver.min.js'
{ state } = require '/imports/ui/components/searchForm.coffee'
{ buildQuery } = require '/imports/ui/components/searchForm.coffee'

Template.portfolios.onCreated ->

  @portfolio = new ReactiveVar ''
  @likeUserIds = new ReactiveVar []
  @designerId = new ReactiveVar ''
  @visible = new ReactiveVar true
  @nonVisible = new ReactiveVar true

  @autorun =>
    @subscribe 'portfolio.like.users', @likeUserIds.get()

Template.portfolios.onRendered ->

  @autorun =>
    unless Meteor.user()
      return
    if Meteor.user().profile.isAdmin
      @subscribe 'portfolios'
    else
      if Meteor.user().profile.isManager
        @designerId.set Meteor.user().profile.designerId
        @subscribe 'designer.portfolios', @designerId.get()
      else
        @designerId.set Meteor.userId()
        @subscribe 'designer.portfolios', @designerId.get()

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
    swal "포트폴리오 미선택", "포트폴리오를 선택해 주세요", "error"
    false
  else
    true

Template.portfolios.events

  'change input[name=visible]': (e, t)->
    value = $('[name=visible]').is ':checked'
    t.visible.set value

  'change input[name=nonVisible]': (e, t)->
    value = $('[name=nonVisible]').is ':checked'
    t.nonVisible.set value

  'change input[name=checkAll]': (e)->
    checked = $('input[name=checkAll]').is ':checked'
    $('input.visible-check').prop 'checked', checked

  'click #btnVisible': (e, t) ->
    unless checkSelectedCheckbox()
      return
    for element in $('tbody tr').find(":checkbox:checked")
      portfolio = Blaze.getData(element)
      Meteor.call 'portfolio.visible', portfolio._id

  'click #btnNovisible': (e, t) ->
    unless checkSelectedCheckbox()
      return
    for element in $('tbody tr').find(":checkbox:checked")
      portfolio = Blaze.getData(element)
      Meteor.call 'portfolio.nonVisible', portfolio._id

  'click #btnRemove': (e)->
    unless checkSelectedCheckbox()
      return
    swal
      title: "삭제"
      text: "포트폴리오를 삭제하시겠습니까?"
      type: "warning"
      showCancelButton: true
      cancelButtonText: '취소'
#      confirmButtonColor: "#DD6B55"
      confirmButtonText: "삭제"
      closeOnConfirm: false
      html: false
    , ->
      for element in $('tbody tr').find(":checkbox:checked")
        portfolio = Blaze.getData(element)
        Meteor.call 'portfolio.delete', portfolio._id, portfolio.designerId,
          isActive: false
      clearAllCheckbox()
      swal "결과", "삭제 되었습니다.", "success"

  'click #btnAddPortfolio' : (e, t) ->
    FlowRouter.go 'addPortfolio'

  'click #btnExcel': (e)->

    query = buildQuery()
    rawData = []
    Portfolios.find(query).map (portfolio) ->

      year = portfolio.workedYear
      month = portfolio.workedMonth
      day = portfolio.workedDay
      designer = Meteor.users.findOne(portfolio.designerId)
      products = Products.find(portfolioId : portfolio._id)
      likesCount = if portfolio.likeUserIds then portfolio.likeUserIds.length else 0

      obj = {}
      obj['생성일'] = portfolio.createdAt
      obj['노출상태'] = if portfolio.isVisible is false then 'X' else 'O'
      obj['이름'] = portfolio.title
      obj['작업일'] = year.concat('-',month,'-',day)
      obj['디자이너'] = designer.profile.designerName
      obj['이미지수 '] = portfolio.imageUrl.length
      obj['상품 수'] = products.count()
      obj['리뷰 수'] = portfolio.viewCount
      obj['찜된 수'] = likesCount

      rawData.push obj

    csv = json2csv rawData, true, true
    blob = new Blob [csv], {type: "text/plain;charset=utf-8;",}
    #    console.log 'blob', csv
    saveAs blob, "portfolio.csv"

  'click .portfolioTitle': (e, t) ->
    if Meteor.user().profile.isApproved
      portolio = Blaze.getData(e.target)
      FlowRouter.go 'editPortfolio', {id : portolio._id}
    else if Meteor.user().profile.isAdmin
      portolio = Blaze.getData(e.target)
      window.open('http://home-liaison.com/contentManagement/designers/'+portolio.designerId+'/portfolios/'+portolio._id)

  'click .likeCount' : (e, t) ->
    portfolio = Blaze.getData(e.target)
    t.portfolio.set portfolio
    t.likeUserIds.set portfolio.likeUserIds
    $('.likersModal').modal 'show'

Template.portfolios.helpers
  portfolios: ->
    query = buildQuery()
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
    Portfolios.find query, options

  pageTotalCount: ->
    query = {}
    Portfolios.find(query).count()

  totalCount: ->
    Counts.get 'users.total.counts'

  status: (isVisible)->
    if isVisible then 'O' else 'X'

  dateFormat: (date)->
    moment(date).format('YYYY-MM-DD')

  designerName : (designerId) ->
    designer = Meteor.users.findOne(designerId)
    designer?.profile.designerName

  arrayCount : (array) ->
    if array is undefined
      '0'
    else
      array.length

  portfolioLikeUsers : ->
    unless Template.instance().portfolio.get().likeUserIds
      return
    Meteor.users.find
      _id:
        $in : Template.instance().portfolio.get().likeUserIds

  productCount : (portfolioId) ->
    Products.find(portfolioId : portfolioId).count()

  reviewCount : (portfolioId) ->
    Reviews.find(portfolioId : portfolioId).count()

  workedMonthFormat : (workedMonth) ->
    if workedMonth
      '- ' + workedMonth
    else
      ''



