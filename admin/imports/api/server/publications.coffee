{ publishComposite } = require 'meteor/reywood:publish-composite'

Meteor.publish

#########################
# Users - users / designers
#########################

  'portfolio.like.users' : (likeUserIds) ->
    Meteor.users.find
      _id :
        $in : likeUserIds

  'designers': ->
    Meteor.users.find
      'profile.isDesigner' : true
      'profile.isActive' : true

  'designer': (designerId)->
    Meteor.users.find( designerId )

  'managers': (designerId) ->
    Meteor.users.find
      'profile.isActive': true
      'profile.isManager' : true
      'profile.designerId' : designerId


#########################
# Menu - notices / FAQ / terms
#########################
  'notices': ->
    Notices.find(isActive : true)

  'notice': ( noticeId ) ->
    Notices.find( noticeId )

  'faqs': ->
    Faqs.find(isActive : true)

  'faq': ( faqId ) ->
    Faqs.find( faqId )

  'terms': ->
    Terms.find()

  'notification': (userId) ->
    Notification.find
      userId : userId

#########################
# Marketing - Event, Tag
#########################

  'tags': ->
    Tags.find(isActive: true)

  'events': ->
    Events.find(isActive : true)

  'event': (eventId) ->
    Events.find
      _id : eventId
      isActive : true


  'adjustments': ->
    query =
      adjustmentAt:
        $lte: new Date()
    Adjustment.find query

  'adjustments.designer': (designerId) ->
    query =
      designerId : designerId
      adjustmentAt:
        $lte: new Date()
    Adjustment.find query

#########################
# Menu - portfolios
#########################

Meteor.publishComposite 'portfolios',
  find: ->
    query =
      isActive: true
    options =
      sort:
        createdAt: -1
    result = Portfolios.find( query, options )
    return result
  children: [
    find: (portfolios) ->
      Meteor.users.find portfolios.designerId
  ,
    find: (portfolios) ->
      Products.find portfolioId : portfolios._id
  ,
    find: (portfolios) ->
      Reviews.find portfolioId : portfolios._id
  ]

Meteor.publishComposite 'designer.portfolios', (designerId) ->
  find: ->
    query =
      designerId : designerId
      isActive: true
    options =
      sort:
        createdAt: -1
    result = Portfolios.find( query, options )
    return result
  children: [
    find: (portfolios) ->
      Meteor.users.find portfolios.designerId
  ,
    find: (portfolios) ->
      Products.find portfolioId : portfolios._id
  ,
    find: (portfolios) ->
      Reviews.find portfolioId : portfolios._id
  ]

Meteor.publishComposite 'portfolio', (portfolioId) ->
  find: ->
    result = Portfolios.find portfolioId
    return result
  children: [
    find: (portfolio) ->
      Meteor.users.find portfolio.designerId
  ]

#########################
# Menu - product
#########################

Meteor.publishComposite 'products',
  find: ->
    query =
      isActive: true
    options =
      sort:
        createdAt: -1
    result = Products.find( query, options )
    return result
  children: [
    find: (product) ->
      Portfolios.find product.portfolioId
  ,
    find: (product) ->
      Meteor.users.find product.designerId
  ,
    find: (product) ->
      Reviews.find productId : product._id
  ,
    find: (product) ->
      Sales.find productId : product._id
  ]

Meteor.publishComposite 'designer.products', (designerId) ->
  find: ->
    query =
      designerId: designerId
      isActive: true
    options =
      sort:
        createdAt: -1
    result = Products.find( query, options )
    return result
  children: [
    find: (product) ->
      Portfolios.find product.portfolioId
  ,
    find: (product) ->
      Reviews.find productId : product._id
  ,
    find: (product) ->
      Sales.find productId : product._id
  ]

Meteor.publishComposite 'product', (productId) ->
  find: ->
    result = Products.find productId
    return result
  children: [
    find: (product) ->
      Meteor.users.find product.portfolioId
  ]

#########################
# Monitoring - QNA
#########################

Meteor.publishComposite 'qnas.admin.site',
  find: ->
    result = Qnas.find
      'type' :
        $ne : '디자이너 문의'
    return result
  children: [
    find: (qnas) ->
      Meteor.users.find( _id : qnas.userId )
  ,
    find: (qnas) ->
      Portfolios.find(qnas.portfolioId)
  ,
    find: (qnas) ->
      Products.find(qnas.productId)
  ]

Meteor.publishComposite 'qnas.admin.designer',
  find: ->
    result = Qnas.find( 'type' : '디자이너 문의' )
    return result
  children: [
    find: (qnas) ->
      Meteor.users.find( _id : qnas.userId )
  ]

Meteor.publishComposite 'qnas.designer', (userId) ->
  find: ->
    result = Qnas.find( 'designerId' : userId )
    return result
  children: [
    find: (qnas) ->
      Meteor.users.find( _id : qnas.userId )
  ]

Meteor.publishComposite 'reviews',
  find: ->
    result = Reviews.find( isActive : true )
    return result
  children: [
    find: (reviews) ->
      Meteor.users.find( _id : reviews.userId )
  ,
    find: (reviews) ->
      Products.find( _id : reviews.productId )
  ,
    find: (reviews) ->
      Portfolios.find( _id : reviews.portfolioId )
  ,
    find: (reviews) ->
      Meteor.users.find( _id : reviews.designerId )
  ]


#########################
# adjustments
#########################

Meteor.publishComposite 'adjustments.sales.products', (saleIds) ->
  find: ->
    query =
      _id:
        $in : saleIds
    result = Sales.find query

    return result
  children: [
    find: (sales) ->
      Products.find( _id : sales.productId )
  ,
    find: (sales) ->
      Portfolios.find( _id : sales.portfolioId )
  ]

Meteor.publishComposite 'sales',
  find: ->
    result = Sales.find()
    return result
  children: [
    find: (sales) ->
      Meteor.users.find( _id : sales.userId )
  ,
    find: (sales) ->
      Products.find( _id : sales.productId )
  ,
    find: (sales) ->
      Portfolios.find( _id : sales.portfolioId )
  ,
    find: (sales) ->
      Meteor.users.find( _id : sales.designerId )
  ]

Meteor.publishComposite 'sales.designer', (designerId) ->
  find: ->
    result = Sales.find( 'designerId' : designerId )
    return result
  children: [
    find: (sales) ->
      Meteor.users.find( _id : sales.userId )
  ,
    find: (sales) ->
      Products.find( _id : sales.productId )
  ,
    find: (sales) ->
      Portfolios.find( _id : sales.portfolioId )
  ]

Meteor.publishComposite 'users', ->
  find: ->
    result = Meteor.users.find( 'profile.isActive': true )
    return result
  children: [
    find: (users) ->
      Sales.find( userId : users._id)
#  ,
#    find: (users) ->
#      Portfolios.find
#        users._id
#          $in: users._id
#    그때 설명 못들은 찾으려는 DB안에있는 배열을 $in 하는법
  ]

#########################
# schedule
#########################

#TODO 불러오는 이전 날짜는 가져오지 않도록 수정할것
Meteor.publishComposite 'designer.schedule', (designerId) ->
  find: ->
    result = Sales.find( 'designerId' : designerId )
    return result
  children: [
    find: (schedule) ->
      if schedule.type is 'holiday'
        return
      Products.find( _id : schedule.productId )
  ,
    find: (schedule) ->
      if schedule.type is 'holiday'
        return
      Portfolios.find( _id : schedule.portfolioId )
  ]
