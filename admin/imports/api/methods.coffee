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

updateTags = (portfolioId, tagArray) ->
  tagArray.forEach (tag)->
    matchingTag = Tags.findOne
      tagName : tag
    if matchingTag
      Tags.update matchingTag._id,
        $inc:
          registerCount: 1
    else
      newTag =
        tagName : tag
        registerCount : 1
#        designerId : Meteor.userId()
#        portfolioId : portfolioId
        clickCount : 0
        isRecommend : false
        isActive: true
        isVisible: true
        createdAt: new Date()
      Tags.insert newTag

#    Meteor.users.update Meteor.userId(),
#      $addToSet:
#        'profile.tags' : tag

updateUserTags = (portfolioId)->
#  console.log 'inside updateUserTags'
  portfolioForTags = Portfolios.findOne(portfolioId)
#  console.log 'portfolioForTags: ', portfolioForTags
  tagsToUpdate = portfolioForTags.allTagsInArray()
#  console.log 'tagsToUpdate: ', tagsToUpdate
#  console.log 'userId: ', userId
  result = Meteor.users.update portfolioForTags.designerId,
    $set:
      'profile.tags': tagsToUpdate
  console.log 'result: ', result

addAdjustments = (paymentInfo, saleId, lastWorkDay, ratio)->
  if lastWorkDay is undefined
    arrayLength = paymentInfo.effectiveDays.length
    lastWorkDay = paymentInfo.effectiveDays[arrayLength - 1]
#    console.log 'lastWorkDay : ', lastWorkDay

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
    when '#payment-form' then adjustmentPrice = (price - (price * commission / 100)) - ((price - (price * commission / 100)) * 0.033)

  console.log 'moment(adjustmentAt).toDate() : ', moment(adjustmentAt).toDate()

  query =
    adjustmentAt : moment(adjustmentAt).toDate()
    designerId : paymentInfo.designerId
  adjustment = Adjustment.findOne query

  console.log 'adjustment : ', adjustment

  if adjustment
#      adjustment.paymentInfo.push paymentInfo
    adjustment.saleIds.push saleId
    adjustment.totalPrice += (price * ratio / 100)
    adjustment.totalAdjustmentPrice += (adjustmentPrice * ratio / 100)

    query =
      adjustmentAt : moment(adjustmentAt).toDate()
      designerId : paymentInfo.designerId

    Adjustment.update query,
      $set:
        adjustment

  else
#      console.log 'adjustmentPrice : ', adjustmentPrice
    obj =
      startsAt : moment(startsAt).toDate()
      endsAt : moment(endsAt).toDate()
      adjustmentAt : moment(adjustmentAt).toDate()
#        designerSales : []
      isComplete : false
      completedAt : '-'
      designerId : paymentInfo.designerId
      saleIds : [saleId]
#        paymentInfo : [paymentInfo]
      totalPrice : (price * ratio / 100)
      totalAdjustmentPrice : (adjustmentPrice * ratio / 100)

    Adjustment.insert obj

Meteor.methods
##########################
# Users / Designers
##########################

  'users.managers.add' : (managerInfo) ->
    Accounts.createUser managerInfo

  'users.changeAdmin' : (userId, isAdmin) ->
    Meteor.users.update userId,
      $set :
        isAdmin

  'designers.approval' : (userId) ->
    Meteor.users.update userId,
      $set:
        'profile.isApproved' : true
        'profile.approvedAt' : new Date()
    query =
      'profile.designerId' : userId
    Meteor.users.update query,
      $set:
        'profile.isApproved' : true
    , multi: true

  'designer.update.externalUser': (userId, email) ->
    Meteor.users.update userId,
      $set:
        'profile.isExternalUser' : false
#    Accounts.sendResetPasswordEmail userId, email

  'designers.revocation' : (userId) ->
    Meteor.users.update userId,
      $set:
        'profile.isApproved' : false
        'profile.approvedAt' : '-'
    query =
      'profile.designerId' : userId
    Meteor.users.update query,
      $set:
        'profile.isApproved' : false
    , multi: true

  'designers.editProfile': (profile, designerId) ->
    currentUser = undefined
    if Meteor.user().profile.isManager
      currentUser = Meteor.users.findOne(designerId)
    else
      currentUser = Meteor.user()
    Meteor.users.update designerId,
      $set:
        profile : _.defaults profile, currentUser.profile

    Sales.update designerId : designerId,
      $set:
        designerName : profile.designerName

  'designer.businessLicenseNumber.exists': (number, type)->
    if type isnt '프리랜서(사업자 없음)'
      query =
        'profile.businessLicenseNumber': number
        _id:
          $ne: Meteor.userId()
      anyUserWithTheSameLicenseNumber = Meteor.users.findOne(query)
      if anyUserWithTheSameLicenseNumber then true else false
    else
      false

  'designer.editDesignerInfo': (profile) ->
    profile = _.extend profile,
      isApproved : false
      approvedAt : '-'
    currentUser = Meteor.user()
    Meteor.users.update Meteor.userId(),
      $set:
        profile : _.defaults profile, currentUser.profile

    Adjustment.update designerId : Meteor.userId(),
      $set:
        bankName : profile.bankName

    query =
      'profile.designerId' : Meteor.userId()
    Meteor.users.update query,
      $set:
        'profile.isApproved' : false
    , multi: true

  'designer.editSns' : (sns, designerId) ->
    currentUser = undefined
    if Meteor.user().profile.isManager
      currentUser = Meteor.users.findOne( designerId )
    else
      currentUser = Meteor.user()
    currentUser.profile = _.extend currentUser.profile,
      homepageUrl : sns.homepageUrl
      blogUrl : sns.blogUrl
      instagramUrl : sns.instagramUrl
      twitterUrl : sns.twitterUrl
      facebookUrl : sns.facebookUrl
    Meteor.users.update designerId,
      $set:
        profile : currentUser.profile

  'designer.account.edit' : (account, designerId) ->
    currentUser = undefined
    if Meteor.user().profile.isManager
      currentUser = Meteor.users.findOne( designerId )
    else
      currentUser = Meteor.user()
    currentUser.profile = _.extend currentUser.profile,
      bankName : account.bankName
      accountName : account.accountName
      accountNumber : account.accountNumber
    Meteor.users.update designerId,
      $set:
        profile : currentUser.profile

  'user.dropout': (userId) ->
    Meteor.users.update userId,
      $set:
        'profile.isActive': false

    Portfolios.update designerId : designerId,
      $set:
        isActive : false
        isVisible : false

    Products.update designerId : designerId,
      $set:
        isActive : false
        isVisible : false

##########################
# Portfolio
##########################
  'portfolios.add': (portfolio, designerId)->
    _.extend portfolio,
      designerId : designerId
      createdAt: new Date()
      updatedAt: new Date()
      viewCount : 0
      isActive: true
      isVisible : true
      productCount : 0
#      reviewScore : 0
    portfolioId = Portfolios.insert portfolio
    updateTags(portfolioId, portfolio.tags)
    updateUserTags(portfolioId)

    Meteor.users.update designerId,
      $inc:
        'profile.portfolioCount' : 1

  'portfolios.edit': (portfolioId, portfolio)->
    portfolio.updatedAt = new Date()
#    portfolio = _.omit portfolio, '_id'
    Portfolios.update portfolioId,
      $set: portfolio
    updateTags(portfolioId, portfolio.tags)
    updateUserTags(portfolioId)

    Sales.update portfolioId : portfolioId,
      $set:
        portfolioTitle : portfolio.title

  'portfolio.visible': (portfolioId)->
    Portfolios.update portfolioId,
      $set:
        isVisible : true

  'portfolio.nonVisible': (portfolioId)->
    Portfolios.update portfolioId,
      $set:
        isVisible : false

  'portfolio.delete': (portfolioId, designerId)->
    Portfolios.update portfolioId,
      $set:
        isActive : false

    Meteor.users.update designerId,
      $inc:
        'profile.portfolioCount' : -1

##########################
# Product
##########################
  'products.add': (product, designerId)->
    _.extend product,
      designerId : designerId
      createdAt: new Date()
      updatedAt: new Date()
      isActive: true
      isVisible : true
      isEndless : false
      commission : 20
    Products.insert product

    Portfolios.update product.portfolioId,
      $inc:
        productCount: 1

    Meteor.users.update designerId,
      $inc:
        'profile.productCount' : 1

  'products.edit': (productId, product)->
    product.updatedAt = new Date()
    product = _.omit product, '_id'
    Products.update productId,
      $set: product

    Sales.update productId : productId,
      $set:
        productTitle : product.title

  'product.visible': (productId)->
    Products.update productId,
      $set:
        isVisible : true

  'product.nonVisible': (productId)->
    Products.update productId,
      $set:
        isVisible : false

  'product.delete': (productId, designerId)->
    Products.update productId,
      $set:
        isActive : false

    Meteor.users.update designerId,
      $inc:
        'profile.productCount' : -1

    product = Products.findOne productId
    Portfolios.update product.portfolioId,
      $inc:
        productCount: -1

  'product.commission.edit': (commissionInfo) ->
#    product = Products.findOne commission.productId
#    _.extend product,
    Products.update commissionInfo.productId,
      $set:
        startsAt : commissionInfo.startsAt
        endsAt : commissionInfo.endsAt
        isEndless : commissionInfo.isEndless
        commission : commissionInfo.commission

#########################
# Menu - notices / FAQ / terms
#########################

  'news.read': (newsId)->
    Notification.update newsId,
      $set:
        read : true

  'notices.add': (notice)->
    _.extend notice,
      createdAt: new Date()
      updatedAt: new Date()
      isVisible: true
      isActive: true
    Notices.insert notice

  'notices.update': (noticeId, notice)->
    notice.updatedAt = new Date()
    notice = _.omit notice, '_id'
    Notices.update noticeId,
      $set: notice

  'faqs.add': (faq)->
    _.extend faq,
      createdAt: new Date()
      updatedAt: new Date()
      isVisible: true
      isActive: true
    Faqs.insert faq

  'faqs.update': (faqId, faq)->
    faq.updatedAt = new Date()
    faq = _.omit faq, '_id'
    Faqs.update faqId,
      $set: faq

  'terms.update': (type, text)->
    Terms.upsert
      type: type
    ,
      $set:
        text: text
        updatedAt: new Date()

#########################
# Monitoring - QNA
#########################

  'qnas.insert' : (qna, designerId) ->
    qna = _.extend qna,
      userId : designerId
      isAnswered : false
      createdAt : new Date()
    Qnas.insert qna

  'qnas.answer': (qnaId, qna)->
    qna.answeredAt = new Date()
    qna.isAnswered = true
    qna = _.omit qna, '_id'
    Qnas.update qnaId,
      $set: qna

#########################
# Marketing - Event , Tag
#########################

  'adjustments.complete': (adjustments) ->
    Adjustment.update adjustments._id,
      $set:
        isComplete: true
        completedAt: new Date()

    for saleId in adjustments.saleIds
      sale = Sales.findOne saleId
      product = Products.findOne sale.productId
      portfolio = Portfolios.findOne sale.portfolioId
      notificationSend(portfolio.title+' / '+product.title+' 정산이 완료됬습니다.', adjustments.designerId, 'adjustments')

  'adjustments.nonComplete': (adjustmentsId) ->
    Adjustment.update adjustmentsId,
      $set:
        isComplete: false
        completedAt: '-'

  'payment.cancel': (cancelInfo) ->

    HTTP.call 'post', "https://api.iamport.kr/users/getToken", {
      data :
   
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
        status : '관리자 환불'
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
      adjustment.totalAdjustmentPrice -= adjustmentPrice
      saleIds = adjustment.saleIds
      saleIds.splice(saleIds.indexOf(sale._id),1)

      Adjustment.update query,
        $set:
          totalPrice: adjustment.totalPrice
          totalAdjustmentPrice: adjustment.totalAdjustmentPrice
          saleIds : saleIds

#      console.log 'adjustment.saleIds.length : ', adjustment.saleIds.length
#      if adjustment.saleIds.length is 0
#        Adjustment.remove query

      ratio = 100 - cancelInfo.ratio
      addAdjustments(sale, sale._id, new Date(), ratio)

  'events.insert' : (event) ->
    event = _.extend event,
      createdAt : new Date()
      updatedAt : new Date()
      isActive : true
      isVisible : true
      isPopup : false
    Events.insert event

  'events.update' : (event, eventId) ->
    event = _.extend event,
      updatedAt : new Date()
    Events.update eventId,
      $set :
        event

  'events.visible' : (eventId, isVisible) ->
    Events.update eventId,
      $set :
        isVisible : isVisible

  'events.popup' : (eventId, isPopup) ->
    Events.update eventId,
      $set :
        isPopup : isPopup

  'events.remove' : (eventId) ->
    Events.update eventId,
      $set :
        isActive : false

  'tags.visible' : (tagId, isVisible) ->
    Tags.update tagId,
      $set:
        isVisible : isVisible

  'tags.recommend' : (tagId, isRecommend) ->
    Tags.update tagId,
      $set:
        isRecommend: isRecommend

  'tags.remove' : (tagId) ->
    Tags.update tagId,
      $set:
        isActive : false


  'schedules.add.holiday' : (schedule) ->
    schedule = _.extend schedule,
      type : 'holiday'
      createdAt : new Date()
#    console.log 'schedule  : ', schedule
    Sales.insert schedule

  'schedules.remove.holiday' : (schedule) ->
    Sales.remove
      type: 'holiday'
      designerId: schedule.designerId
      effectiveDays: schedule.holiday

  'review.visible' : (reviewId) ->
    Reviews.update reviewId,
      $set:
        isVisible : true

  'review.nonVisible' : (reviewId) ->
    Reviews.update reviewId,
      $set:
        isVisible : false

  'review.delete' : (reviewId) ->
    Reviews.update reviewId,
      $set:
        isActive : false

  'aligo' : (text, mobile) ->
    msg = encodeURIComponent("#{text}")
    
      if error
        console.log 'error :', error
      else
        console.log 'response : ', response

  'mandrill' : (toEmail, toName, title, mailDateObject) ->
    console.log 'toEmail : ', toEmail
    console.log 'toName : ', toName
    console.log 'title : ', title
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
