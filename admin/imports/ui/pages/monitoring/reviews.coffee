require './reviews.tpl.jade'

{ saveAs } = require '/imports/api/client/FileSaver.min.js'
{ state } = require '/imports/ui/components/searchForm.coffee'
{ buildQuery } = require '/imports/ui/components/searchForm.coffee'

Template.reviews.onCreated ->

  @subscribe 'reviews'
  @visible = new ReactiveVar true
  @nonVisible = new ReactiveVar true

Template.reviews.onRendered ->

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
    swal "리뷰 미선택", "리뷰를 선택해 주세요", "error"
    false
  else
    true

Template.reviews.events

  'click .designerTitle': (e, t) ->
    review = Blaze.getData(e.target)
    window.open('http://home-liaison.com/contentManagement/designers/'+review.designerId)

  'click .portfolioTitle': (e, t) ->
    review = Blaze.getData(e.target)
    window.open('http://home-liaison.com/contentManagement/designers/'+review.designerId+'/portfolios/'+review.portfolioId)

  'click .productTitle': (e, t) ->
    review = Blaze.getData(e.target)
    window.open('http://home-liaison.com/contentManagement/designers/'+review.designerId+'/portfolios/'+review.portfolioId+'/products/'+review.productId)

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
      review = Blaze.getData(element)
      console.log review
      Meteor.call 'review.visible', review._id

  'click #btnNovisible': (e, t) ->
    unless checkSelectedCheckbox()
      return
    for element in $('tbody tr').find(":checkbox:checked")
      review = Blaze.getData(element)
      Meteor.call 'review.nonVisible', review._id

  'click #btnRemove': (e)->
    unless checkSelectedCheckbox()
      return
    swal
      title: "삭제"
      text: "리뷰를 삭제하시겠습니까?"
      type: "warning"
      showCancelButton: true
      cancelButtonText: '취소'
#      confirmButtonColor: "#DD6B55"
      confirmButtonText: "삭제"
      closeOnConfirm: false
      html: false
    , ->
      for element in $('tbody tr').find(":checkbox:checked")
        review = Blaze.getData(element)
        Meteor.call 'review.delete', review._id,
          isActive: false
      clearAllCheckbox()
      swal "결과", "삭제 되었습니다.", "success"

  'click #btnExcel': (e)->
    query = buildQuery()
    rawData = []
    Reviews.find(query).map (review) ->

      user = Meteor.users.findOne(review.userId)
      designer = Meteor.users.findOne(review.designerId)
      portfolio = Portfolios.findOne(review.portfolioId)
      product = Products.findOne(review.productId)

      obj = {}
      obj['노출상태'] = if review.isVisible is false then 'X' else 'O'
      obj['생성일'] = review.createdAt
      #      obj['문의자 이메일'] = user.emails[0].address
      obj['리뷰 점수'] = review.score
      obj['사용자'] = user.profile.userName
      obj['이메일'] = user.emails[0].address
      obj['상품'] = product.title
      obj['포트폴리오'] = portfolio.title
      obj['디자이너'] = designer.profile.designerName
      rawData.push obj
    csv = json2csv rawData, true, true
    blob = new Blob [csv], {type: "text/plain;charset=utf-8;",}
    #    console.log 'blob', csv
    saveAs blob, "review.csv"

Template.reviews.helpers
  Reviews: ->
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
    Reviews.find query, options

  pageTotalCount: ->
    query = {}
    Reviews.find(query).count()

  status: (isVisible)->
    if isVisible then 'O' else 'X'

  dateFormat: (date)->
    moment(date).format('YYYY-MM-DD')

  userName : (userId) ->
   user = Meteor.users.findOne(userId)
   unless user
     return
   user.profile.userName

  userEmail : (userId) ->
    user = Meteor.users.findOne(userId)
    unless user
      return
    user.emails[0].address

  productName : (productId) ->
    product = Products.findOne(productId)
    unless product
      return
    product.title

  portfolioName : (portfolioId) ->
    portfolio = Portfolios.findOne(portfolioId)
    unless portfolio
      return
    portfolio.title