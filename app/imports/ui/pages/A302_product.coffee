require './A302_product.tpl.jade'

{ bucket } = require '/imports/ui/pages/bucket.coffee'
{ Page } = require '/imports/api/client/common.coffee'

isMobile =
  Android: ->
    if navigator.userAgent.match(/Android/i) == null then false else true
  BlackBerry: ->
    if navigator.userAgent.match(/BlackBerry/i) == null then false else true
  IOS: ->
    if navigator.userAgent.match(/iPhone|iPad|iPod/i) == null then false else true
  any: ->
    isMobile.Android() or isMobile.BlackBerry() or isMobile.IOS()

Template.A302_product.onCreated ->

  bucket.set 'designerId', undefined
  bucket.set 'portfolioId', undefined
  bucket.set 'productId', undefined
  @designerId = FlowRouter.getParam 'designerId'
  @portfolioId = FlowRouter.getParam 'portfolioId'
  @productId = FlowRouter.getParam 'productId'
  @subscribe 'product', @productId
  @subscribe 'portfolio', @portfolioId
  @subscribe 'product.reviews', @productId
  @subscribe 'product.schedules', @productId, @designerId
  @starScore = new ReactiveVar ''
  @product = new ReactiveVar ''
  @portfolio = new ReactiveVar ''

Template.A302_product.onRendered ->

  @autorun =>
    if @subscriptionsReady()
      Tracker.afterFlush =>
        $(".reserveDatePicker").datepicker
          minDate: 0

  @autorun =>
    product = Products.findOne @productId
    unless  product
      return
    @product.set product

  @autorun =>
    portfolio = Portfolios.findOne @portfolioId
    unless  portfolio
      return
    @portfolio.set portfolio

  @autorun =>
    if @subscriptionsReady()
      Tracker.afterFlush =>
        galleryTop = new Swiper('.gallery-top',
          spaceBetween: 10)
        galleryThumbs = new Swiper('.gallery-thumbs',
          spaceBetween: 10
          centeredSlides: true
          slidesPerView: 'auto'
          touchRatio: 0.2
          slideToClickedSlide: true)

        galleryTop.params.control = galleryThumbs;
        galleryThumbs.params.control = galleryTop;

  #TODO 오토런 밖으로 함수를 빼기
  @autorun =>
    sumEffectiveDays = []
    holidayArray = []
    disabledDays = []
    screenedDate = []
    query =
      designerId : @designerId
      type : 'holiday'
    #TODO 홀리데이만 따로 스케줄(스키마 이름 홀리데이로 변경)에 등록한거 뽑아오기
    holidays = Sales.find(query)              #뮤조건 쉬는 휴일을 구함
    if holidays.count()
      holidays.forEach (holiday) ->
        holiday.effectiveDays.forEach (date) ->
          holidayArray.push date

    if @product.get().isUnlimited
      i = 0
      while i < holidayArray.length
        disabledDays.push moment(holidayArray[i]).format('M/D/YYYY')
        i++

      console.log disabledDays
    else
      result = Sales.find(productId : Template.instance().productId)     #해당 날짜에 있는 상품들을 찾음
      if result.count()
        result.forEach (schedule) ->
          if schedule.status is '결제'
            sumEffectiveDays = $.merge(sumEffectiveDays, schedule.effectiveDays) #DB에서 날짜들 Eech 돌면서 하나의 배열로 합침

            screenDate = (dateArray, minimunCount) ->
              datesOrderedByCount = _.countBy(dateArray, (date) ->
                date
              )
              screenedDate = []
              _.each datesOrderedByCount, (element, index) ->
                if element >= minimunCount
                  screenedDate.push moment(index).format('M/D/YYYY')
                return
              screenedDate

            screenedDate = screenDate(sumEffectiveDays, Template.instance().product.get().possibleWorkPerDay) #원하는 갯수만큼 중복된 날짜들만 배열로 뽑아님

      if screenedDate.length isnt 0 or holidayArray.length isnt 0
        $.merge(screenedDate, holidayArray)
        screenedDate.forEach (date) -> #each 돌면서 예약불가능한 이전 날짜들 계산
          i = 0
          while i < Template.instance().product.get().workDurationInDay
            momentDate = moment(date).subtract(i, 'days').toDate()
            disabledDays.push moment(momentDate).format('M/D/YYYY')
            i++

#    console.log '중복되는 값들 : ', screenedDate
#    if screenedDate.length isnt 0 or disabledDays.length isnt 0
#      console.log 'screenedDate :', screenedDate
#      console.log 'disabledDays :', disabledDays
#      $.merge(screenedDate, disabledDays)
#    console.log '최종 적으로 안보여져야되는 값 ', disabledDays

    #datepicker에서 중복되는 날짜를 disable 해주는 부분
    #TODO jquery 부분 momentJS, coffee 이용해서 코드 수정하기
    disableAllTheseDays = (date) ->
      m = date.getMonth()
      d = date.getDate()
      y = date.getFullYear()
      if $.inArray(m + 1 + '/' + d + '/' + y, disabledDays) != -1
        return [ false ]
      return [true]

    if disabledDays.length isnt 0
      $(".reserveDatePicker").datepicker("destroy")
      $(".reserveDatePicker").datepicker
        minDate: 0
        beforeShowDay: disableAllTheseDays


Template.A302_product.events

  'click .likes-btn' : (e, t) ->

    portfolio = t.portfolio.get()
    if portfolio.likeUserIds and Meteor.userId() in portfolio.likeUserIds
      Meteor.call 'portfolios.likes.remove', portfolio._id, (error, result)->
        if error
          console.log error
        else
          sweetAlert '찜', '포트폴리오가 찜 되었습니다.', 'success'
    else
      Meteor.call 'portfolios.likes.add', portfolio._id, (error, result)->
        if error
          console.log error
        else
          sweetAlert '찜', '찜 목록에서 제외되었습니다.', 'success'


  'click #facebookButton': (e, t) ->
    bucket.set 'designerId', t.designerId
    bucket.set 'portfolioId', t.portfolioId
    bucket.set 'productId', t.productId
    FlowRouter.go 'login'
#    Meteor.loginWithFacebook {}, (error) ->
#      if error
#        console.log 'error ', error
#      else
#        FlowRouter.go 'product', {designerId : bucket.get('designerId'), portfolioId : bucket.get('portfolioId'), productId: bucket.get('productId')}

  'click .login-button': (e, t) ->
    bucket.set 'designerId', t.designerId
    bucket.set 'portfolioId', t.portfolioId
    bucket.set 'productId', t.productId
    FlowRouter.go 'login'

  'click .tabs li' : (e, t) ->
    tabName = $(e.currentTarget).attr('name')
    $('.active').removeClass('active')
    $('li[name="'+tabName+'"]').addClass('active')

  'click #btnPayment' : (e, t) ->
    unless Meteor.userId()
      sweetAlert '상품 구매', '로그인한 사용자만 이용가능합니다.', 'warning'
      return

    bucket.set 'reserveDate', $(".reserveDatePicker").val()
    FlowRouter.go 'payment', {designerId : t.designerId, portfolioId : t.portfolioId, productId: t.productId}, { reserveDate : $(".reserveDatePicker").val() }

Template.A302_product.helpers

  product : ->
#    Products.findOne(Template.instance().productId)
    Template.instance().product.get()

  portfolio : ->
    Portfolios.findOne()

  onOfflineType : (type) ->
    if type is 'online'
      '온라인'
    else
      '오프라인'

  workDay : (day) ->
    if day isnt '0'
      day + '일'

  workHour : (hour) ->
    if hour isnt '0'
      hour + '시간'

  reviews : ->
    reviews = Reviews.find(productId : Template.instance().productId)
    unless  reviews
      return
    reviews

  userName : (userId) ->
    console.log 'userId : ', userId
    user = Meteor.users.findOne(userId)
    unless  user
      return
    console.log 'user : ', user
    user.profile.userName

  starCSS : (num, score) ->
    if score >= num
      'on'
    else
      ''
  productSummary : ->
    unless Template.instance().product.get()
      return
    Template.instance().product.get().productSummary.split('\n')

  comma: (price) ->
    Page.comma(price)

  dateFormat : (date) ->
    moment(date).format('YYYY-MM-DD')

  isMobile: ->
    isMobile.any()
    console.log 'isMobile.any() : ', isMobile.any()

    if isMobile.any() is false
      return true
    if isMobile.any() is true
      return false

#    switch num
#      when 'num1'
#        if score >= 1 then 'on' else ''
#      when 'num2'
#        if starScore >= 2 then 'on' else ''
#      when 'num3'
#        if starScore >= 3 then 'on' else ''
#      when 'num4'
#        if starScore >= 4 then 'on' else ''
#      when 'num5'
#        if starScore >= 5 then 'on' else ''
#      when 'num6'
#        if starScore >= 6 then 'on' else ''
#      when 'num7'
#        if starScore >= 7 then 'on' else ''
#      when 'num8'
#        if starScore >= 8 then 'on' else ''
#      when 'num9'
#        if starScore >= 9 then 'on' else ''
#      when 'num10'
#        if starScore >= 10 then 'on' else ''
#      else
#        ''