#console.log 'methods.coffee loaded!!!!!!!!!!!!!!!!!!!!!'
#@Universities = new Mongo.Collection 'universities'
if Meteor.isServer
  mandrill = require 'mandrill-api/mandrill'
  mandrill_client = new mandrill.Mandrill('XqxEd7djZNA79VNeIuLeEg');

notificationSend = (text, userId, type)->
  options =
    text: text
    userId: userId
    read: false
    type: type
    createdAt: new Date()
  Notification.insert options


addAdjustments = (paymentInfo, saleId, lastWorkDay, ratio)->
  if lastWorkDay is undefined
    arrayLength = paymentInfo.effectiveDays.length
    lastWorkDay = paymentInfo.effectiveDays[arrayLength - 1]
    console.log 'lastWorkDay : ', lastWorkDay

  momentDay1 = moment(lastWorkDay).set({'date' : 1, 'hour' : 0, 'minute' : 0, 'second' : 0, 'millisecond': 0})
  momentDay7 = moment(lastWorkDay).set('date', 7)
  momentDay8 = moment(lastWorkDay).set({'date' : 8, 'hour' : 0, 'minute' : 0, 'second' : 0, 'millisecond': 0})
  momentDay14 = moment(lastWorkDay).set('date', 14)
  momentDay15 = moment(lastWorkDay).set({'date' : 15, 'hour' : 0, 'minute' : 0, 'second' : 0, 'millisecond': 0})
  momentDay21 = moment(lastWorkDay).set('date', 21)
  momentDay22 = moment(lastWorkDay).set({'date' : 22, 'hour' : 0, 'minute' : 0, 'second' : 0, 'millisecond': 0})
  momentDay30 = moment(lastWorkDay).endOf("month")


  startsAt = undefined
  endsAt = undefined
  adjustmentAt = undefined
  if moment(lastWorkDay).isBetween(momentDay1, momentDay7, null, '[]')
#      console.log '1~7'
    startsAt = momentDay1
    endsAt = momentDay7
    adjustmentAt = moment(lastWorkDay).set('date', 16)
  else if moment(lastWorkDay).isBetween(momentDay8, momentDay14, null, '[]')
#      console.log '8~14'
    startsAt = momentDay8
    endsAt = momentDay14
    adjustmentAt = moment(lastWorkDay).set('date', 23)
  else if moment(lastWorkDay).isBetween(momentDay15, momentDay21, null, '[]')
#      console.log '15~21'
    startsAt = momentDay15
    endsAt = momentDay21
    adjustmentAt = moment(lastWorkDay).endOf("month")
  else if moment(lastWorkDay).isBetween(momentDay22, momentDay30, null, '[]')
#      console.log '22~30'
    startsAt = momentDay22
    endsAt = momentDay30
    adjustmentAt = moment(moment(lastWorkDay).set('date', 9)).add(1, 'months')

  #    console.log 'startsAt : ', startsAt
  price = paymentInfo.price / 1.1
  commission = paymentInfo.commission
  adjustmentPrice = 0
  designer = Meteor.users.findOne(paymentInfo.designerId)
  switch designer.profile.businessType
    when '법인 사업자(일반과세)' then adjustmentPrice = (price - (price * commission / 100)) * 1.1
    when '개인 사업자(일반과세)' then adjustmentPrice = (price - (price * commission / 100)) * 1.1
    when '개인 사업자(간이과세)' then adjustmentPrice = price - (price * commission / 100)
    when '프리랜서(사업자 없음)' then adjustmentPrice = (price - (price * commission / 100)) - ((price - (price * commission / 100)) * 0.033)

#  console.log 'moment(adjustmentAt).toDate() : ', moment(adjustmentAt).toDate()

  query =
    adjustmentAt : moment(adjustmentAt).toDate()
    designerId : paymentInfo.designerId
  adjustment = Adjustment.findOne query

#  console.log 'adjustment : ', adjustment

  if adjustment
#      adjustment.paymentInfo.push paymentInfo
    adjustment.saleIds.push saleId
    console.log 'adjustment.totalPrice : ' , (paymentInfo.price * ratio / 100)
    adjustment.totalPrice += (paymentInfo.price * ratio / 100)
    console.log 'adjustment.totalAdjustmentPrice : ', Math.round(adjustmentPrice * ratio / 100)
    adjustment.totalAdjustmentPrice += Math.round(adjustmentPrice * ratio / 100)

    query =
      adjustmentAt : moment(adjustmentAt).toDate()
      designerId : paymentInfo.designerId

    Adjustment.update query,
      $set:
        adjustment

  else
#      console.log 'adjustmentPrice : ', adjustmentPrice

    designer = Meteor.users.findOne paymentInfo.designerId

    console.log 'price : ', price
    console.log 'ratio : ', ratio
    console.log 'adjustment.totalPrice : ' , (price * ratio / 100)
    console.log 'adjustment.totalAdjustmentPrice : ', Math.round(adjustmentPrice * ratio / 100)

    obj =
      startsAt : moment(startsAt).toDate()
      endsAt : moment(endsAt).toDate()
      adjustmentAt : moment(adjustmentAt).toDate()
#        designerSales : []
      isComplete : false
      completedAt : '-'
      designerId : paymentInfo.designerId
      bankName : designer.profile.bankName
      saleIds : [saleId]
#        paymentInfo : [paymentInfo]
      totalPrice : (paymentInfo.price * ratio / 100)
      totalAdjustmentPrice : Math.round(adjustmentPrice * ratio / 100)

    Adjustment.insert obj


Meteor.methods
##########################
# User
##########################

  'user.profileUpdate' : (profile) ->
    currentUser = Meteor.user()
    Meteor.users.update Meteor.userId(),
      $set:
        profile : _.defaults profile, currentUser.profile

  'user.dropout': ->
    Meteor.users.update Meteor.userId(),
      $set:
        'profile.isActive': false

    Portfolios.update designerId : Meteor.userId(),
      $set:
        isActive : false
        isVisible : false

    Products.update designerId : Meteor.userId(),
      $set:
        isActive : false
        isVisible : false

  'user.designerApply': (profile) ->
    profile = _.extend profile,
      isDesigner : true
      portfolioCount : 0
      productCount : 0
    currentUser = Meteor.user()
    Meteor.users.update Meteor.userId(),
      $set:
        profile : _.defaults profile, currentUser.profile

  'users.businessLicenseNumber.exists': (number, type)->
    if type isnt '프리랜서(사업자 없음)'
      query =
        'profile.businessLicenseNumber': number
      anyUserWithTheSameLicenseNumber = Meteor.users.findOne(query)
      if anyUserWithTheSameLicenseNumber then true else false
    else
      false

##########################
# designer
##########################

  'designer.update.viewCount' : (desingerId) ->
    Meteor.users.update desingerId,
      $inc :
        'profile.viewCount' : 1

##########################
# Qna
##########################

  'qnas.insert' : (qna) ->
    qna = _.extend qna,
      userId : Meteor.userId()
      isAnswered : false
      createdAt : new Date()
    Qnas.insert qna

    if qna.type is '디자이너 문의'
      portfolio = Portfolios.findOne qna.portfolioId
      notificationSend(portfolio.title+'문의가 접수됬습니다.('+qna.email+')', qna.designerId, 'qna')

##########################
# like
##########################

  'portfolios.likes.add' : (portfolioId) ->
    Portfolios.update portfolioId,
      $addToSet:
        likeUserIds :  Meteor.userId()

  'portfolios.likes.remove' : (portfolioId) ->
    Portfolios.update portfolioId,
      $pull:
        likeUserIds :  Meteor.userId()

##########################
# tag
##########################

  'tag.click.id' : (tagId) ->
    console.log 'tagId : ', tagId
    Tags.update tagId,
      $inc :
        clickCount : 1

  'tag.click.name' : (tagName) ->
    Tags.update tagName : tagName,
      $inc :
        clickCount : 1

##########################
# payment
##########################

  'payment.temporaryStorage': (formInfo) ->
    Meteor.users.update Meteor.userId(),
      $set:
        'profile.formInfo' : formInfo

  'payment.add' : (paymentInfo) ->
    paymentInfo = _.extend paymentInfo,
      createdAt : new Date()
      type : 'reservation'
      status : '결제'
    saleId = Sales.insert paymentInfo
    paymentInfo.saleId = saleId
    portfolio = Portfolios.findOne paymentInfo.portfolioId
    product = Products.findOne paymentInfo.productId
    user = Meteor.users.findOne paymentInfo.userId
#    notificationSend('[홈리에종]',portfolio.title+' 포트폴리오 '+product.title+' 상품이 판매되었습니다. '+user.profile.userName+' 고객에게 연락하고 프로젝트를 시작해 주세요!', paymentInfo.designerId, 'sales')
    notificationSend(portfolio.title+' / '+product.title+'이 판매됬습니다.('+user.profile.userName+' / '+user.emails[0].address+')', paymentInfo.designerId, 'sales')

    addAdjustments(paymentInfo, saleId, undefined, 100)

    return saleId

#    schedule = _.extend schedule,
#      type : 'reservation'
#      createdAt : new Date()
#    Sales.insert schedule

  'payment.cancel': (cancelInfo) ->

    HTTP.call 'post', "https://api.iamport.kr/users/getToken", {
      data :
        imp_key : '7188483898255321'
        imp_secret : '05z9vXYzdvq9Xb2SHBu8j8RpTw60LnALs9UY6TxkoYul9weR8JZsSRSLoYM9lmUOwPMCIjX7istrYIj7'
    }, (error, token) ->
      if error
        console.log 'error :', error
      else
        console.log 'token : ', token.data.response.access_token

        HTTP.call 'post', "https://api.iamport.kr/payments/cancel/?_token=" + token.data.response.access_token, {
          data :
            imp_uid : cancelInfo.imp_uid
            merchant_uid : cancelInfo.merchant_uid
            amount : cancelInfo.amount
            reason : cancelInfo.reason
            refund_holder : cancelInfo.refund_holder
            refund_bank : cancelInfo.refund_bank
            refund_account : cancelInfo.refund_account
        }, (error, result) ->
          if error
            console.log 'error :', error
          else
            console.log 'cancel success'
#            console.log 'result :', result

    Sales.update imp_uid : cancelInfo.imp_uid,
      $set:
        status : '사용자 취소'
        cancelPrice : cancelInfo.amount

    sale = Sales.findOne cancelInfo.saleId

    arrayLength = sale.effectiveDays.length
    lastWorkDay = sale.effectiveDays[arrayLength - 1]

    console.log 'lastWorkDay : ', lastWorkDay

    momentDay1 = moment(lastWorkDay).set({'date' : 1, 'hour' : 0, 'minute' : 0, 'second' : 0, 'millisecond': 0})
    momentDay7 = moment(lastWorkDay).set('date', 7)
    momentDay8 = moment(lastWorkDay).set({'date' : 8, 'hour' : 0, 'minute' : 0, 'second' : 0, 'millisecond': 0})
    momentDay14 = moment(lastWorkDay).set('date', 14)
    momentDay15 = moment(lastWorkDay).set({'date' : 15, 'hour' : 0, 'minute' : 0, 'second' : 0, 'millisecond': 0})
    momentDay21 = moment(lastWorkDay).set('date', 21)
    momentDay22 = moment(lastWorkDay).set({'date' : 22, 'hour' : 0, 'minute' : 0, 'second' : 0, 'millisecond': 0})
    momentDay30 = moment(lastWorkDay).endOf("month")

    startsAt = undefined
    endsAt = undefined
    adjustmentAt = undefined
    if moment(lastWorkDay).isBetween(momentDay1, momentDay7, null, '[]')
#      console.log '1~7'
      startsAt = momentDay1
      endsAt = momentDay7
      adjustmentAt = moment(lastWorkDay).set('date', 16)
    else if moment(lastWorkDay).isBetween(momentDay8, momentDay14, null, '[]')
#      console.log '8~14'
      startsAt = momentDay8
      endsAt = momentDay14
      adjustmentAt = moment(lastWorkDay).set('date', 23)
    else if moment(lastWorkDay).isBetween(momentDay15, momentDay21, null, '[]')
#      console.log '15~21'
      startsAt = momentDay15
      endsAt = momentDay21
      adjustmentAt = moment(lastWorkDay).endOf("month")
    else if moment(lastWorkDay).isBetween(momentDay22, momentDay30, null, '[]')
#      console.log '22~30'
      startsAt = momentDay22
      endsAt = momentDay30
      adjustmentAt = moment(moment(lastWorkDay).set('date', 9)).add(1, 'months')

#    console.log 'adjustmentAt.toDate() : ', adjustmentAt.toDate()
#    console.log 'sale.designerId ', sale.designerId

    query =
      adjustmentAt : adjustmentAt.toDate()
      designerId : sale.designerId

    adjustment = Adjustment.findOne query

#    console.log 'adjustment : ', adjustment
#    console.log 'adjustment.totalPrice : ', adjustment.totalPrice
#    console.log 'cancelInfo.amount : ', cancelInfo.amount
    number = adjustment.totalPrice - cancelInfo.amount
    if number is 0
      console.log '0 momney'
      Adjustment.remove query
    else
      console.log 'no 0 momney'
      price = sale.price / 1.1
      commission = sale.commission
      adjustmentPrice = 0
      designer = Meteor.users.findOne(sale.designerId)
      switch designer.profile.businessType
        when '법인 사업자(일반과세)' then adjustmentPrice = (price - (price * commission / 100)) * 1.1
        when '개인 사업자(일반과세)' then adjustmentPrice = (price - (price * commission / 100)) * 1.1
        when '개인 사업자(간이과세)' then adjustmentPrice = price - (price * commission / 100)
        when '프리랜서(사업자 없음)' then adjustmentPrice = (price - (price * commission / 100)) - ((price - (price * commission / 100)) * 0.033)

      adjustment.totalPrice -= sale.price
      adjustment.totalAdjustmentPrice -= Math.round(adjustmentPrice)
      saleIds = adjustment.saleIds
      saleIds.splice(saleIds.indexOf(sale._id),1)

      Adjustment.update query,
        $set:
          totalPrice: adjustment.totalPrice
          totalAdjustmentPrice: adjustment.totalAdjustmentPrice
          saleIds : saleIds

#      if adjustment.saleIds.length is 0
#        Adjustment.remove query

      ratio = 100 - cancelInfo.ratio
      addAdjustments(sale, sale._id, new Date(), ratio)


#      price = cancelInfo.amount
#      commission = sale.commission
#      adjustmentPrice = 0
#      switch designer.profile.businessType
#        when '법인 사업자(일반과세)' then adjustmentPrice = (price - (price * commission / 100)) * 1.1
#        when '개인 사업자(일반과세)' then adjustmentPrice = (price - (price * commission / 100)) * 1.1
#        when '개인 사업자(간이과세)' then adjustmentPrice = price - (price * commission / 100)
#        when '프리랜서(사업자 없음)' then adjustmentPrice = (price - (price * commission / 100)) - ((price - (price * commission / 100)) * 0.033)
#
#      adjustment.totalPrice -= price
#      adjustment.totalAdjustmentPrice -= adjustmentPrice
#
#      Adjustment.update query,
#        $set:
#          totalPrice: adjustment.totalPrice
#          totalAdjustmentPrice: adjustment.totalAdjustmentPrice


##########################
# review
##########################

  'review.add' : (review) ->
    user = Meteor.users.findOne review.userId
    portfolio = Portfolios.findOne review.portfolioId
    product = Products.findOne review.productId
#    notificationSend('[홈리에종]',portfolio.title+' 포트폴리오에 대한 '+user.profile.userName+' 고객님의 문의가 접수되었습니다. 홈페이지를 통해 답변 해주세요. ', review.designerId, 'products')
    notificationSend(portfolio.title+' / '+product.title+' 리뷰가 생성됬습니다.('+user.profile.userName+' / '+user.emails[0].address+')', review.designerId, 'review')
    review = _.extend review,
      isActive : true
      isVisible : true
      createdAt : new Date()
    Reviews.insert review

    portfolio.tags.forEach (tag)->
      Tags.update tagName : tag,
        $inc :
          score : review.score
          reviewCount : 1

    portfolioReviews = Reviews.find
      portfolioId : review.portfolioId

    portfolioReviewTotalScore = 0
    portfolioReviews.forEach (review) ->
      portfolioReviewTotalScore += review.score

    Portfolios.update review.portfolioId,
      $set:
        reviewScore : Math.round((portfolioReviewTotalScore/portfolioReviews.count()) * 10) / 10

    designerReviews = Reviews.find
      designerId : review.designerId

    designerReviewTotalScore = 0
    designerReviews.forEach (review) ->
      designerReviewTotalScore += review.score

    Meteor.users.update review.designerId,
      $set:
        'profile.reviewScore' : Math.round((designerReviewTotalScore/designerReviews.count()) * 10) / 10

##########################
# portfolio
##########################

  'portfolio.update.viewCount' : (portfolioId) ->
    Portfolios.update portfolioId,
      $inc :
        viewCount : 1

  'aligo' : (text, mobile) ->
    msg = encodeURIComponent("#{text}")
    HTTP.call 'get', "https://apis.aligo.in/?userid=hliaison&key=mnpm8c1h078n2gtpoqgzck6gpfvg0dq2&sender=02-2039-2252&receiver=#{mobile}&msg=#{msg}", {}, (error, response) ->
      if error
        console.log 'error :', error
      else
        console.log 'response : ', response

  'mandrill' : (toEmail, toName, title, mailDateObject) ->
    template_name = mailDateObject.templateName
    template_content = [ {
      'name': 'content1'
      'content': mailDateObject.content1
    },{
      'name': 'content2'
      'content': mailDateObject.content2
    },{
      'name': 'content3'
      'content': mailDateObject.content3
    },{
      'name': 'content4'
      'content': mailDateObject.content4
    },{
      'name': 'content5'
      'content': mailDateObject.content5
    },{
      'name': 'content6'
      'content': mailDateObject.content6
    },{
      'name': 'content7'
      'content': mailDateObject.content7
    } ]
    message =
      'html': '<p>테스트로 씁니다</p>'
      'text': 'testsetst'
      'subject': title
      'from_email': 'support@home-liaison.com'
      'from_name': '홈리에종'
      'to': [ {
        'email': toEmail
        'name': toName
        'type': 'to'
      } ]
    async = false
    ip_pool = 'Main Pool'
    send_at = new Date()

    mandrill_client.messages.sendTemplate {
      'template_name': template_name
      'template_content': template_content
      'message': message
      'async': async
      'ip_pool': ip_pool
      'send_at': send_at
    }, ((result) ->
      console.log result

      return
    ), (e) ->
      console.log 'A mandrill error occurred: ' + e.name + ' - ' + e.message
      return
