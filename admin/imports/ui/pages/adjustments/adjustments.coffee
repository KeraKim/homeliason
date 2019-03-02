require './adjustments.tpl.jade'

{ saveAs } = require '/imports/api/client/FileSaver.min.js'
{ state } = require '/imports/ui/components/searchForm.coffee'
{ buildQuery } = require '/imports/ui/components/searchForm.coffee'

Template.adjustments.onCreated ->
#  @subscribe 'sales'
  @subscribe 'adjustments'
  @subscribe 'designers'
  @sale = new ReactiveVar ''
  @saleIds = new ReactiveVar undefined

Template.adjustments.onRendered ->

  @autorun =>
    if @saleIds.get() isnt undefined
      @subscribe 'adjustments.sales.products', @saleIds.get()

  searchIdTexts = []
  initial =
    id: 'title'
    text: '은행'
  searchIdTexts.push initial
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

Template.adjustments.events

  'click .saleList-button': (e, t) ->
    designerAdjustments = Blaze.getData(e.target)
    t.saleIds.set designerAdjustments.saleIds
    $('.saleListModal').modal 'show'

  'click #btnComplete': (e, t) ->
    unless checkSelectedCheckbox()
      return
    for element in $('tbody tr').find(":checkbox:checked")
      adjustments = Blaze.getData(element)
      console.log 'adjustments : ', adjustments
      Meteor.call 'adjustments.complete', adjustments

  'click #btnNonComplete': (e, t) ->
    unless checkSelectedCheckbox()
      return
    for element in $('tbody tr').find(":checkbox:checked")
      adjustments = Blaze.getData(element)
      Meteor.call 'adjustments.nonComplete', adjustments._id

  'change input[name=checkAll]': (e)->
    checked = $('input[name=checkAll]').is ':checked'
    $('input.visible-check').prop 'checked', checked

  'click #btnExcel': (e)->
    rawData = Notifications.find().fetch()
    csv = json2csv rawData, true, true
    blob = new Blob [csv], {type: "text/plain;charset=utf-8;",}
    saveAs blob, "notices.csv"

Template.adjustments.helpers
  adjustments : ->

    searchText = state.get 'searchText'
    startsAt = state.get 'startsAt'
    endsAt = state.get 'endsAt'
    durations = state.get 'durations'

    query = {}

    if searchText isnt ''
      query.bankName =
        $regex: searchText

    if durations is 'all'
      query.adjustmentAt =
        $lt: moment(endsAt).endOf('day').toDate()
    else
      query.adjustmentAt =
        $gte: moment(startsAt).toDate()
        $lt: moment(endsAt).endOf('day').toDate()

#    query = buildQuery()

#    query = {}
#    query =
#      adjustmentAt:
#        $lte: new Date()
    page = FlowRouter.getQueryParam 'page' or 1
    limit = 10
    options =
      limit: limit
      skip: (page - 1) * limit
      sort:
        adjustmentAt: -1
    adjustments = Adjustment.find query, options
    unless adjustments
      return

    adjustments

  salesProducts: ->
    saleIds = Template.instance().saleIds.get()
    if saleIds
      sales = Sales.find
        _id:
          $in : saleIds
      unless sales
        return

      salesGroup = _.groupBy sales.fetch(), (sale) ->
        sale.productId

      array = $.map(salesGroup, (value, index) ->
        [ value ]
      )

      array

  totalPrice: (type) ->
    saleIds = Template.instance().saleIds.get()
    if saleIds
      sales = Sales.find
        _id:
          $in : saleIds
      unless sales
        return

      totalPrice = 0
      totalTax = 0
      totalAdjustment = 0
      sales.forEach (sale) ->
        price = sale.price / 1.1
        commission = sale.commission
        adjustmentPrice = 0
        designer = Meteor.users.findOne(sale.designerId)
        switch designer.profile.businessType
          when '법인 사업자(일반과세)' then adjustmentPrice = (price - (price * commission / 100)) * 1.1
          when '개인 사업자(일반과세)' then adjustmentPrice = (price - (price * commission / 100)) * 1.1
          when '개인 사업자(간이과세)' then adjustmentPrice = price - (price * commission / 100)
          when '프리랜서(사업자 없음)' then adjustmentPrice = (price - (price * commission / 100)) - ((price - (price * commission / 100)) * 0.033)
        totalPrice += sale.price
        totalAdjustment += adjustmentPrice
      totalTax = totalPrice - totalAdjustment

      console.log 'type : ', type
      if type is 'totalPrice'
        return totalPrice
      else if type is 'totalTax'
        return totalTax
      else if type is 'totalAdjustment'
        return totalAdjustment

  productName: (productId) ->
    product = Products.findOne(productId)
    unless product
      return
    product.title

  portfolioName: (portfolioId) ->
    portfolio = Portfolios.findOne(portfolioId)
    unless portfolio
      return
    portfolio.title

  productTotalPrice: (price, length) ->
    price * length

  dateFormat: (date)->
    if date is '-'
      '-'
    else
      moment(date).format('YYYY-MM-DD')

  isComplete: (boolean) ->
    if boolean
      '정산완료'
    else
      '미처리'

  serName : (userId) ->
    user = Meteor.users.findOne(userId)
    if user?.profile?.userName
      user.profile.userName

  userEmail : (userId) ->
    user = Meteor.users.findOne(userId)
    if user?.emails[0].address
      user.emails[0].address

  product : (productId) ->
    product = Products.findOne(productId)
    if product?.title
      product.title

  portfolio : (portfolioId) ->
    portfolio = Portfolios.findOne(portfolioId)
    if portfolio?.title
      portfolio.title

  designer : (designerId, fieldName) ->
    designer = Meteor.users.findOne(designerId)
    if designer?.profile?[fieldName]
      designer.profile[fieldName]

  pageTotalCount : ->
    query = buildQuery()
    Notices.find(query).count()

  totalCount : ->
    Notices.find().count()

  totalVisibleCount : ->
    Notices.find(isVisible: true).count()

  requestPopup : ->
    Template.instance().sale.get()

