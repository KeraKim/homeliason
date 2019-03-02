require './sales.tpl.jade'

{ saveAs } = require '/imports/api/client/FileSaver.min.js'
{ state } = require '/imports/ui/components/searchForm.coffee'
{ buildQuery } = require '/imports/ui/components/searchForm.coffee'

print = (printArea) ->
  win = window.open()
  self.focus()
  win.document.open()
  win.document.write '<html><head><title></title><style>'
  win.document.write 'body, td {font-falmily: Verdana; font-size: 10pt;}'
  win.document.write '</style></haed><body>'
  win.document.write printArea
  win.document.write '</body></html>'
  win.document.close()
  win.print()
  win.close()

requestTextFormat = (text) ->
  switch text
    when 'buy' then '구매의사 있음'
    when 'keep' then '현재가구 유지'
    when 'remove' then '배치하지 않음'
    when 'nonRequest' then '요청하지 않습니다.'
    when 'notKnow' then '잘 모르겠습니다.'
    when 'request' then '요청합니다.'

Template.sales.onCreated ->
  @designerId = new ReactiveVar ''
#  @subscribe 'sales'
  @sale = new ReactiveVar ''
  @cancel = new ReactiveVar ''

Template.sales.onRendered ->

  @autorun =>
    unless Meteor.user()
      return
    if Meteor.user().profile.isAdmin
      @subscribe 'sales'
    else
      if Meteor.user().profile.isManager
        @designerId.set Meteor.user().profile.designerId
        @subscribe 'sales.designer', @designerId.get()
      else
        @designerId.set Meteor.userId()
        @subscribe 'sales.designer', @designerId.get()

  searchIdTexts = []
  initial =
    id: 'buyerName'
    text: '구매자명'
  searchIdTexts.push initial
  searchIdTexts.push
    id: 'buyerEmail'
    text: '구매자 이메일'
  searchIdTexts.push
    id: 'productTitle'
    text: '상품'
  searchIdTexts.push
    id: 'portfolioTitle'
    text: '포트폴리오'
  searchIdTexts.push
    id: 'designerName'
    text: '디자이너'
  state.set 'searchIdTexts', searchIdTexts
  state.set 'currentSearchIdText', initial
  state.set 'startsAt', ''

Template.sales.events

  'click #print-button': (e, t) ->
    console.log $('.request-modal-content')
    console.log $('.request-modal-content')[0]
    console.log $('.request-modal-content')[0].innerHTML
    print($('.request-modal-content')[0].innerHTML)

  'click .designerTitle': (e, t) ->
    sale = Blaze.getData(e.target)
    window.open('http://home-liaison.com/contentManagement/designers/'+sale.designerId)

  'click .portfolioTitle': (e, t) ->
    sale = Blaze.getData(e.target)
    window.open('http://home-liaison.com/contentManagement/designers/'+sale.designerId+'/portfolios/'+sale.portfolioId)

  'click .productTitle': (e, t) ->
    sale = Blaze.getData(e.target)
    window.open('http://home-liaison.com/contentManagement/designers/'+sale.designerId+'/portfolios/'+sale.portfolioId+'/products/'+sale.productId)

  'click #btnExcel': (e)->
    query = buildQuery()
    rawData = []
    Sales.find(query).map (sale) ->

      user = Meteor.users.findOne sale.userId
      product = Products.findOne sale.productId
      portfolio = Portfolios.findOne sale.portfolioId
      length = sale.effectiveDays.length

      cancelPrice = 0
      if sale.cancelPrice
        cancelPrice = sale.cancelPrice

      mobile = sale.detail.mobile
      str = mobile.replace(/[^0-9]/g, '')
      hyphenMobile = ''
      if str.length < 11
        hyphenMobile += str.substr(0, 3)
        hyphenMobile += '-'
        hyphenMobile += str.substr(3, 3)
        hyphenMobile += '-'
        hyphenMobile += str.substr(6)
      else
        hyphenMobile += str.substr(0, 3)
        hyphenMobile += '-'
        hyphenMobile += str.substr(3, 4)
        hyphenMobile += '-'
        hyphenMobile += str.substr(7)

      obj = {}
      obj['판매일'] = sale.createdAt
      obj['시작일'] = sale.effectiveDays[0]
      obj['종료일'] = sale.effectiveDays[length - 1]
      obj['구매자명'] = user.profile.userName
      obj['구매자 이메일'] = user.emails[0].address
      obj['상품'] = product.title
      obj['포트폴리오'] = portfolio.title
      obj['가격'] = sale.price - cancelPrice
      obj['상태'] = sale.status
      obj['주거유형'] = sale.detail.homeType
      obj['전화번호'] = hyphenMobile
      obj['공간정보 URL'] = sale.detail.placeInfoFileUrl
      obj['좋아하는 이미지 URL'] = sale.detail.likeImageFileUrl
      obj['우편번호'] = if sale.detail.zipcode then sale.detail.zipcode else ''
      obj['주소'] = if sale.detail.sido then sale.detail.sido else ''
      obj['상세주소'] = if sale.detail.gugun then sale.detail.gugun else ''
      obj['평수'] = if sale.detail.size_pyung then sale.detail.size_pyung else ''
      obj['미터'] = if sale.detail.size_meter then sale.detail.size_meter else ''
      obj['방갯수'] = if sale.detail.roomCount then sale.detail.roomCount else ''
      obj['욕실갯수'] = if sale.detail.bathCount then sale.detail.bathCount else ''
      obj['요청공간'] = if sale.detail.requestPlace then sale.detail.requestPlace else ''
      obj['오프라인서비스 기타사항'] = if sale.detail.offlineServiceOtherRequest then sale.detail.offlineServiceOtherRequest else ''

      if sale.detail.isFurnitureStyling
        furniture = sale.detail.furnitureArray
        obj['방종류'] = furniture[0].room
        obj['책상'] = requestTextFormat furniture[0].desk
        obj['의자'] = requestTextFormat furniture[0].chair
        obj['식탁'] = requestTextFormat furniture[0].table
        obj['서랍장'] = requestTextFormat furniture[0].chest
        obj['쇼파'] = requestTextFormat furniture[0].sofa
        obj['침대'] = requestTextFormat furniture[0].bed
        obj['기타'] = furniture[0].furnitureStylingOtherRequest
        obj['제품 구매대행'] = requestTextFormat furniture[0].agent
        obj['부분 시공 여부'] = requestTextFormat furniture[0].partBuild
      else
        obj['방종류'] = ''
        obj['책상'] = ''
        obj['의자'] =''
        obj['식탁'] = ''
        obj['서랍장'] = ''
        obj['쇼파'] = ''
        obj['침대'] = ''
        obj['기타'] =''
        obj['제품 구매대행'] = ''
        obj['부분 시공 여부'] = ''

      if sale.detail.isFabricStyling
        fabric = sale.detail.fabricArray
        obj['방종류'] = fabric[0].room
        obj['커튼 전체 사이즈'] = if fabric[0].curtainSize then fabric[0].curtainSize else ''
        obj['커튼 창 사이즈'] = if fabric[0].curtainWindowSize then fabric[0].curtainWindowSize else ''
        obj['블라인드 전체 사이즈'] = if fabric[0].blindSize then fabric[0].blindSize else ''
        obj['블라인드 창 사이즈'] = if fabric[0].blindWindowSize then fabric[0].blindWindowSize else ''
        obj['기타 전체 사이즈'] = if fabric[0].otherSize then fabric[0].otherSize else ''
        obj['기타 창 사이즈'] = if fabric[0].otherWindowSize then fabric[0].otherWindowSize else ''
        obj['기타'] = if fabric[0].fabricStylingOtherRequest then fabric[0].fabricStylingOtherRequest else ''
        obj['패브릭 시공 요청'] = if fabric[0].fabricStylingOtherRequest then requestTextFormat fabric[0].fabricBuild else ''
      else
        obj['방종류'] = ''
        obj['커튼 전체 사이즈'] =''
        obj['커튼 창 사이즈'] =''
        obj['블라인드 전체 사이즈'] =''
        obj['블라인드 창 사이즈'] =''
        obj['기타 전체 사이즈'] =''
        obj['기타 창 사이즈'] =''
        obj['기타'] =''
        obj['패브릭 시공 요청'] =''

      obj['요청사항'] = sale.detail.otherRequest
      obj['방문경로'] = sale.detail.visitPath
      obj['서비스 이용목적'] = sale.detail.servicePurpose

      rawData.push obj

    csv = json2csv rawData, true, true
    blob = new Blob [csv], {type: "text/plain;charset=utf-8;",}
    #    console.log 'blob', csv
    saveAs blob, "portfolio.csv"

  'click #title' : (e ,t ) ->
    sale = Blaze.getData(e.target)
    FlowRouter.go 'editNotice', {id: sale._id}

  'click .request-btn' : (e ,t ) ->
    sale = Blaze.getData(e.target)
    t.sale.set sale
    $('.requestModal').modal 'show'

  'click .cancel-btn' : (e ,t ) ->
    sale = Blaze.getData(e.target)
    t.cancel.set sale
    $('.cancelModal').modal 'show'

  'click .detail-btn' : (e ,t ) ->
    sale = Blaze.getData(e.target)
    t.sale.set sale
    $('.detailModal').modal 'show'

  'click #btnCancel': (e, t) ->
    sale = t.cancel.get()
    cancelObject =
      saleId : sale._id
      imp_uid : sale.imp_uid
      merchant_uid : sale.merchant_uid
      amount : sale.price * ($('#ratio option:selected').val() / 100)
      reason : '소비자 변심'
      refund_holder : $('#accountName').val()
      refund_bank : $('#bankName option:selected').val()
      refund_account : $('#accountNumber').val()
      ratio : $('#ratio option:selected').val()

    Meteor.call 'payment.cancel', cancelObject,  (error, result)->
      if error
        console.log error
      else
        console.log result
    $('.cancelModal').modal 'hide'

Template.sales.helpers
  sales : ->
    query = buildQuery()
    if Template.instance().designerId.get() isnt ''
      query.designerId = Template.instance().designerId.get()
    #    query = {}
    page = FlowRouter.getQueryParam 'page' or 1
    limit = 10
    options =
      limit: limit
      skip: (page - 1) * limit
      sort:
        createdAt: -1
    Sales.find query, options

  price: (price, cancelPrice) ->
    if cancelPrice
      price - cancelPrice
    else
      price

  cancelClass: (sale, text) ->
    arrayLength = sale.effectiveDays.length
    firstWorkDay = sale.effectiveDays[0]
    lastWorkDay = sale.effectiveDays[arrayLength - 1]
    isBetween = moment(new Date()).isBetween(firstWorkDay, moment(lastWorkDay).set({'hour' : 23, 'minute' : 59, 'second' : 59}), null, '[]')
#    if sale.price is 300
#      console.log 'isBetween : ', isBetween , 'firstWorkDay : ', firstWorkDay, 'lastWorkDay : ', lastWorkDay, 'new Date : ', new Date()
    if isBetween and sale.status is '결제'
      if text is 'text'
        return '환불하기'
      else if text is 'class'
        return 'clickLine cancel-btn'
    else
      '-'

  cancelStatus: (cancelPrice, status, text) ->
    if status is text
      cancelPrice
    else
      '0'

  detailPopup: ->
    sale = Template.instance().sale.get()
    sale

  effectiveDays: (array , text) ->
    if text is 'start'
      moment(array[0]).format('YYYY-MM-DD')
    else if text is 'end'
      length = array.length
      moment(array[length - 1]).format('YYYY-MM-DD')

  dateFormat: (date)->
    moment(date).format('YYYY-MM-DD')

  userName : (userId) ->
    user = Meteor.users.findOne(userId)
    if user?.profile?.userName
      user.profile.userName

  userEmail : (userId) ->
    user = Meteor.users.findOne(userId)
    if user?.emails[0]?.address
      user.emails[0].address

  product : (productId) ->
    product = Products.findOne(productId)
    if product?.title
      product.title

  portfolio : (portfolioId) ->
    portfolio = Portfolios.findOne(portfolioId)
    if portfolio?.title
      portfolio.title

  designer : (designerId) ->
    designer = Meteor.users.findOne(designerId)
    if designer?.profile?.designerName
      designer.profile.designerName

  pageTotalCount : ->
    query = buildQuery()
    if Template.instance().designerId.get() isnt ''
      query.designerId = Template.instance().designerId.get()
    Sales.find(query).count()

  totalCount : ->
    Sales.find().count()

  totalVisibleCount : ->
    Sales.find(isVisible: true).count()

  requestPopup : ->
    Template.instance().sale.get()

  requestText: (text) ->
    switch text
      when 'buy' then  '구매의사 있음'
      when 'keep' then  '현재가구 유지'
      when 'remove' then  '배치하지 않음'
      when 'request' then  '요청합니다'
      when 'nonRequest' then  '요청하지 않습니다'
      when 'notKnow' then  '잘 모르겠습니다'

  effectiveDays: (array, text) ->
    if text is 'start'
      moment(array[0]).format('YYYY-MM-DD')
    else if text is 'end'
      length = array.length
      moment(array[length - 1]).format('YYYY-MM-DD')
