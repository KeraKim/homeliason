require './designerAdjustments.tpl.jade'

{ saveAs } = require '/imports/api/client/FileSaver.min.js'
{ state } = require '/imports/ui/components/searchForm.coffee'
{ buildQuery } = require '/imports/ui/components/searchForm.coffee'

Template.designerAdjustments.onCreated ->
#  @subscribe 'sales'
  @subscribe 'designers'
  @sale = new ReactiveVar ''
  @designerId = new ReactiveVar ''
  @saleIds = new ReactiveVar undefined

Template.designerAdjustments.onRendered ->

  @autorun =>
    if @saleIds.get() isnt undefined
      @subscribe 'adjustments.sales.products', @saleIds.get()


  @autorun =>
    unless Meteor.user()
      return
    if Meteor.user().profile.isManager
      @designerId.set Meteor.user().profile.designerId
      @subscribe 'adjustments.designer', Meteor.user().profile.designerId
    else
      @designerId.set Meteor.userId()
      @subscribe 'adjustments.designer', Meteor.userId()

  searchIdTexts = []
  initial =
    id: 'title'
    text: '상품'
  searchIdTexts.push initial
  searchIdTexts.push
    id: 'email'
    text: '포트폴리오'
  state.set 'searchIdTexts', searchIdTexts
  state.set 'currentSearchIdText', initial
  state.set 'startsAt', ''

Template.designerAdjustments.events

  'click .saleList-button': (e, t) ->
    designerAdjustments = Blaze.getData(e.target)
    t.saleIds.set designerAdjustments.saleIds
    $('.saleListModal').modal 'show'

  'click #btnExcel': (e)->
    rawData = Notifications.find().fetch()
    csv = json2csv rawData, true, true
    blob = new Blob [csv], {type: "text/plain;charset=utf-8;",}
    saveAs blob, "notices.csv"

Template.designerAdjustments.helpers
  adjustments : ->
#    query = buildQuery()
#    query = {
#      adjustmentAt:
#        $lte: new Date()
#    }
    query =
      designerId : Template.instance().designerId.get()
      adjustmentAt:
        $lte: new Date()
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

  userName : (userId) ->
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
#
#  businessType: (designerId) ->
#    designer = Meteor.users.findOne(designerId)
#    if designer?.profile?.designerName
#      designer.profile.designerName
#
#  bankName: (designerId) ->
#    designer = Meteor.users.findOne(designerId)
#    if designer?.profile?.designerName
#      designer.profile.designerName
#
#  accountNumber: (designerId) ->
#    designer = Meteor.users.findOne(designerId)
#    if designer?.profile?.designerName
#      designer.profile.designerName

  pageTotalCount : ->
    query = buildQuery()
    Notices.find(query).count()

  totalCount : ->
    Notices.find().count()

  totalVisibleCount : ->
    Notices.find(isVisible: true).count()

  requestPopup : ->
    Template.instance().sale.get()

