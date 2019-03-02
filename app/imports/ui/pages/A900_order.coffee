require './A900_order.tpl.jade'

{ Page } = require '/imports/api/client/common.coffee'

Template.A900_order.onCreated ->
  @subscribe 'sales', Meteor.userId()
  @sale = new ReactiveVar ''
  @sale = new ReactiveVar ''
  @reviewMode = new ReactiveVar ''
  @starScore = new ReactiveVar ''
  @clickFlag = new ReactiveVar true
  @cancel = new ReactiveVar ''
  @ratio = new ReactiveVar ''

Template.A900_order.onRendered ->

  @autorun =>
    if @reviewMode.get() is 'write'
      @starScore.set 5
      $('.popupTitle').text '리뷰 쓰기'
      $('.reviewContent').attr('readonly', false)
    else if @reviewMode.get() is 'read'
      review = Reviews.findOne saleId : @sale.get()._id
      @starScore.set review.score
      $('.popupTitle').text '리뷰 보기'
      $('.reviewContent').val(review.content)
      $('.reviewContent').attr('readonly', true)

  $(document).on 'wheel mousewheel scroll', '.foundry_modal, .modal-screen', (evt) ->
    $(this).get(0).scrollTop += evt.originalEvent.deltaY
    false

Template.A900_order.events

  'click #cancle-submit': (e, t) ->
    sale = t.cancel.get()
    cancelObject =
      saleId : sale._id
      imp_uid : sale.imp_uid
      merchant_uid : sale.merchant_uid
      amount : sale.price * (t.ratio.get() / 100)
      reason : '소비자 변심'
      refund_holder : $('#accountName').val()
      refund_bank : $('#bankName option:selected').val()
      refund_account : $('#accountNumber').val()
      ratio : t.ratio.get()
    
    Meteor.call 'payment.cancel', cancelObject,  (error, result)->
      if error
        console.log error
      else
        console.log result

        remainingDay = moment(t.cancel.get().effectiveDays[0]).diff(new Date, 'days')

        userMailDateObject = {
          templateName : '[홈리에종] 결제가 취소되었습니다.',
          content1 : sale.portfolioTitle,
          content2 : sale.productTitle,
          content3 : remainingDay,
          content4 : (100 - Number(t.ratio.get())),
          content5 : Math.round(sale.price * (t.ratio.get() / 100))
        }

        Meteor.call 'mandrill', Meteor.user().emails[0].address, Meteor.user().profile.userName, '[홈리에종] 결제가 취소되었습니다.', userMailDateObject, (error, result) ->
          if error
            console.log error
          else
            console.log result

        Meteor.call 'aligo', '[홈리에종]\n '+sale.portfolioTitle+'포트폴리오 '+sale.productTitle+'상품의 결제가 취소 되었습니다. '+remainingDay+'일전 취소로, '+(100 - Number(t.ratio.get()))+'%의 수수료가 부과됩니다. 총 환불액은 '+Math.round(sale.price * (t.ratio.get() / 100))+'원 입니다. 홈리에종을 이용해 주셔서 감사합니다 :) http://home-liaison.com', sale.detail.mobile , (error, result)->
          if error
            console.log error
          else
            console.log result

        designer = Meteor.users.findOne(sale.designerId)
        firstMobileNumber = designer.profile.firstMobileNumber
        meddleMobileNumber = designer.profile.meddleMobileNumber
        lastMobileNumber = designer.profile.lastMobileNumber
        mobile = firstMobileNumber.concat(meddleMobileNumber, lastMobileNumber)

        designerMailDateObject = {
          templateName : '[홈리에종] 고객님의 결제가 취소되었습니다.',
          content1 : Meteor.user().profile.userName,
          content2 : sale.portfolioTitle,
          content3 : sale.productTitle
        }

        Meteor.call 'mandrill', designer.emails[0].address, designer.profile.designerName, '[홈리에종] 고객님의 결제가 취소되었습니다.', designerMailDateObject, (error, result) ->
          if error
            console.log error
          else
            console.log result

        Meteor.call 'aligo', '[홈리에종]\n '+ Meteor.user().profile.userName +'고객님의 '+ sale.portfolioTitle +'포트폴리오 '+ sale.productTitle +'상품에 대한 결제가 취소되었습니다. 일정관리에 참고하시기 바랍니다. http://home-liaison.com', mobile , (error, result)->
          if error
            console.log error
          else
            console.log result

    $('.cancel_modal').toggleClass 'reveal-modal'
    $('.modal-screen').toggleClass 'reveal-modal'

  'click .cancel-button': (e, t ) ->
    sale = Blaze.getData(e.target)
    console.log sale
    t.cancel.set sale
    workStartDate = sale.effectiveDays[0]
    ratio = 0
    remainingDay = moment(workStartDate).diff(new Date, 'days')
    console.log 'remainingDay : ', remainingDay
    if 30 <= remainingDay
      ratio = 100
    else if remainingDay < 30 and remainingDay > 21
      ratio = 90
    else if remainingDay <= 21 and remainingDay > 14
      ratio = 80
    else if remainingDay <= 14 and remainingDay > 7
      ratio = 70
    else if remainingDay <= 7 and remainingDay >= 4
      ratio = 60

    t.ratio.set ratio

    sweetAlert
      title: "결제 취소"
      text: "정말로 결제를 취소 하시겠습니까? 결제금액의 "+ratio+"% 만큼 환급받으실수 있습니다."
      type: "warning"
      showCancelButton: true
      cancelButtonText: '닫기'
#      confirmButtonColor: "#DD6B55"
      confirmButtonText: "결제 취소"
      closeOnConfirm: false
      html: false
    , ->
      sweetAlert.close()
      $('.cancel_modal').toggleClass 'reveal-modal'
      $('.modal-screen').toggleClass 'reveal-modal'
#      Meteor.call 'user.dropout', Accounts.userId(),  (error, result)->
#        if error
#          console.log error
#        else
#          console.log result
#          Meteor.logout()
#      sweetAlert "결과", "회원탈퇴가 되셨습니다..", "success"
#      FlowRouter.go 'index'


  'click .review-btn' : (e, t) ->
    e.preventDefault()
    $('.review_modal').toggleClass 'reveal-modal'
    $('.modal-screen').toggleClass 'reveal-modal'
    $('.reviewContent').val('')
    if $(e.currentTarget).text() is '쓰기'
      t.reviewMode.set 'write'
      t.sale.set Blaze.getData(e.target)
    else
      t.reviewMode.set 'read'
      t.sale.set Blaze.getData(e.target)

  'click #write-btn' : (e, t) ->
    if t.reviewMode.get() is 'write'
      review =
        userId : Meteor.userId()
        designerId : t.sale.get().designerId
        portfolioId : t.sale.get().portfolioId
        productId : t.sale.get().productId
        saleId : t.sale.get()._id
        score : t.starScore.get()
        content : $('.reviewContent').val()

      Meteor.call 'review.add', review, (error) ->
        if error
          console.log error
        else
          $('.review_modal').toggleClass 'reveal-modal'
          $('.modal-screen').toggleClass 'reveal-modal'
    else
      $('.review_modal').toggleClass 'reveal-modal'
      $('.modal-screen').toggleClass 'reveal-modal'

  'click .starImageWrap' : (e, t) ->
    t.clickFlag.set false
    if $(e.target).hasClass('num1')
      t.starScore.set 1
    else if $(e.target).hasClass('num2')
      t.starScore.set 2
    else if $(e.target).hasClass('num3')
      t.starScore.set 3
    else if $(e.target).hasClass('num4')
      t.starScore.set 4
    else if $(e.target).hasClass('num5')
      t.starScore.set 5
    else if $(e.target).hasClass('num6')
      t.starScore.set 6
    else if $(e.target).hasClass('num7')
      t.starScore.set 7
    else if $(e.target).hasClass('num8')
      t.starScore.set 8
    else if $(e.target).hasClass('num9')
      t.starScore.set 9
    else if $(e.target).hasClass('num10')
      t.starScore.set 10

  'mouseenter .starImageWrap' : (e, t) ->
    if t.clickFlag.get()
      if $(e.target).hasClass('num1')
        t.starScore.set 1
      else if $(e.target).hasClass('num2')
        t.starScore.set 2
      else if $(e.target).hasClass('num3')
        t.starScore.set 3
      else if $(e.target).hasClass('num4')
        t.starScore.set 4
      else if $(e.target).hasClass('num5')
        t.starScore.set 5
      else if $(e.target).hasClass('num6')
        t.starScore.set 6
      else if $(e.target).hasClass('num7')
        t.starScore.set 7
      else if $(e.target).hasClass('num8')
        t.starScore.set 8
      else if $(e.target).hasClass('num9')
        t.starScore.set 9
      else if $(e.target).hasClass('num10')
        t.starScore.set 10

Template.A900_order.helpers

  orders : ->

#    query =
#      userId : Meteor.userId()
#    options =
#      sort:
#        createdAt: -1
#
#    sales = Sales.find query, options
#    unless sales
#      return
#
#    sales

    Sales.find
      userId : Meteor.userId()

  cancelDate: (date, status) ->
    if new Date() < moment(date).subtract(3, 'days') and status is '결제'
      true
    else
      false

  dateFormat : (date) ->
    moment(date).format('YYYY-MM-DD')

  designerName : ( designerId ) ->
    designer = Meteor.users.findOne designerId
    unless designer
      return
    designer.profile.designerName

  portfolioName : ( portfolioId ) ->
    portfolio = Portfolios.findOne portfolioId
    unless portfolio
      return
    portfolio.title

  productName : ( productId ) ->
    product = Products.findOne productId
    unless product
      return
    product.title

  review : ( salesId ) ->
    review = Reviews.findOne saleId : salesId
    if review
      '보기'
    else
      '쓰기'

  clickCSS : ->
    reviewMode = Template.instance().reviewMode.get()
    if reviewMode is 'write'
      'write'
    else
      'read'


  starCSS : (num) ->
    starScore = Template.instance().starScore.get()
    switch num
      when 'num1'
        if starScore >= 1 then 'on' else ''
      when 'num2'
        if starScore >= 2 then 'on' else ''
      when 'num3'
        if starScore >= 3 then 'on' else ''
      when 'num4'
        if starScore >= 4 then 'on' else ''
      when 'num5'
        if starScore >= 5 then 'on' else ''
      when 'num6'
        if starScore >= 6 then 'on' else ''
      when 'num7'
        if starScore >= 7 then 'on' else ''
      when 'num8'
        if starScore >= 8 then 'on' else ''
      when 'num9'
        if starScore >= 9 then 'on' else ''
      when 'num10'
        if starScore >= 10 then 'on' else ''
      else
        ''
  comma: (price) ->
    Page.comma(price)

  effectiveDays: (array, text) ->
    if text is 'start'
      moment(array[0]).format('YYYY-MM-DD')
    else if text is 'end'
      length = array.length
      moment(array[length - 1]).format('YYYY-MM-DD')
