require './products.tpl.jade'

{ saveAs } = require '/imports/api/client/FileSaver.min.js'
{ state } = require '/imports/ui/components/searchForm.coffee'
{ buildQuery } = require '/imports/ui/components/searchForm.coffee'

Template.products.onCreated ->

  @designerId = new ReactiveVar ''
  @visible = new ReactiveVar true
  @nonVisible = new ReactiveVar true

Template.products.onRendered ->

#  @autorun =>
#    if Meteor.user()?.profile?.isAdmin
#      @subscribe 'products'
#    else
#      @subscribe 'designer.products', Meteor.userId()

  @autorun =>
    unless Meteor.user()
      return
    if Meteor.user().profile.isAdmin
      @subscribe 'products'
    else
      if Meteor.user().profile.isManager
        @designerId.set Meteor.user().profile.designerId
        @subscribe 'designer.products', @designerId.get()
      else
        @designerId.set Meteor.userId()
        @subscribe 'designer.products', @designerId.get()

  searchIdTexts = []
  initial =
    id: 'title'
    text: '상품'
  searchIdTexts.push initial
  searchIdTexts.push
    id: 'portfolioName'
    text: '포트폴리오'
  state.set 'searchIdTexts', searchIdTexts
  state.set 'currentSearchIdText', initial
  state.set 'startsAt', ''

clearAllCheckbox = ->
  $('input.visible-check').prop 'checked', false
  $('input.visible-check-all').prop 'checked', false

checkSelectedCheckbox = ->
  if 1 > $('tbody tr').find(":checkbox:checked").length
    swal "상품 미선택", "상품을 선택해 주세요", "error"
    false
  else
    true

Template.products.events

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
      product = Blaze.getData(element)
      Meteor.call 'product.visible', product._id

  'click #btnNovisible': (e, t) ->
    unless checkSelectedCheckbox()
      return
    for element in $('tbody tr').find(":checkbox:checked")
      product = Blaze.getData(element)
      Meteor.call 'product.nonVisible', product._id

  'click #btnRemove': (e)->
    unless checkSelectedCheckbox()
      return
    swal
      title: "삭제"
      text: "상품을 삭제하시겠습니까?"
      type: "warning"
      showCancelButton: true
      cancelButtonText: '취소'
#      confirmButtonColor: "#DD6B55"
      confirmButtonText: "삭제"
      closeOnConfirm: false
      html: false
    , ->
      for element in $('tbody tr').find(":checkbox:checked")
        product = Blaze.getData(element)
        Meteor.call 'product.delete', product._id, product.designerId,
          isActive: false
      clearAllCheckbox()
      swal "결과", "삭제 되었습니다.", "success"

  'click #btnAddProduct' : (e, t) ->
    FlowRouter.go 'addProduct'

  'click #btnExcel': (e)->
    query = buildQuery()
    rawData = []
    Products.find(query).map (product) ->

      designer = Meteor.users.findOne(product.designerId)
      portfolio = Portfolios.findOne(product.portfolioId)
      sales = Sales.find(productId : product._id)
      total = 0
      sales.forEach (sale) ->
        total += sale.price
      reviews = Reviews.find(productId : product._id)

      obj = {}
      obj['생성일'] = product.createdAt
      obj['노출상태'] = if product.isVisible is false then 'X' else 'O'
      obj['이름'] = product.title
      obj['포트폴리오'] = portfolio.title
      obj['디자이너'] = designer.profile.designerName
      obj['가격 '] = product.price
      obj['판매 수'] = sales.count()
      obj['총 판매액'] = total
      obj['리뷰 수'] = reviews.count()

      rawData.push obj
    csv = json2csv rawData, true, true
    blob = new Blob [csv], {type: "text/plain;charset=utf-8;",}
    #    console.log 'blob', csv
    saveAs blob, "product.csv"

  'click .productTitle': (e, t) ->
    if Meteor.user().profile.isApproved
      product = Blaze.getData(e.target)
      FlowRouter.go 'editProduct', {id : product._id}
    else if Meteor.user().profile.isAdmin
      product = Blaze.getData(e.target)
      window.open('http://home-liaison.com/contentManagement/designers/'+product.designerId+'/portfolios/'+product.portfolioId+'/products/'+product._id)

  'click .portfolioTitle': (e, t) ->
    if Meteor.user().profile.isAdmin
      product = Blaze.getData(e.target)
      window.open('http://home-liaison.com/contentManagement/designers/'+product.designerId+'/portfolios/'+product.portfolioId)


  'click .commission': (e, t) ->
    product = Blaze.getData(e.target)
    FlowRouter.go 'editCommission', {productId : product._id}


Template.products.helpers
  products: ->
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
    Products.find query, options

  portfolioName : (portfolioId) ->
    portfolio = Portfolios.findOne(portfolioId)
    if portfolio?
      portfolio.title

  designerName : (designerId) ->
    designer = Meteor.users.findOne(designerId)
    if designer?
      designer.profile.designerName

  pageTotalCount: ->
    query = {}
    Products.find(query).count()

  totalCount: ->
    Counts.get 'users.total.counts'

  status: (isVisible)->
    if isVisible then 'O' else 'X'

  dateFormat: (date)->
    moment(date).format('YYYY-MM-DD')

  saleCount : (productId) ->
    Sales.find(productId : productId).count()

  totalPrice : (productId) ->
    sales = Sales.find
      productId : productId
    totalPrice = 0
    sales.forEach (sale)->
      totalPrice += sale.price

    totalPrice

  reviewCount : (productId) ->
    Reviews.find(portfolioId : productId).count()

  commission: (product) ->
    if product.isEndless
      product.commission
    else
      if moment(new Date()).isBetween(product.startsAt, product.endsAt)
        product.commission
      else
        20




