{ publishComposite } = require 'meteor/reywood:publish-composite'

Meteor.publish

#########################
# notices / FAQ / terms
#########################
  'notices': ->
    query =
      isActive: true
      isVisible: true
      startsAt:
        $lte: new Date()

      $or: [
        endsAt:
          $gte: new Date()
      ,
        isEndless: true
      ]

    Notices.find query

  'notice': ( noticeId ) ->
    Notices.find( noticeId )

  'faqs': ->
    Faqs.find(isActive : true)

  'faq': ( faqId ) ->
    Faqs.find( faqId )

  'terms': ->
    Terms.find()

#########################
# schedule
#########################

#  'product.schedules' : (productId) ->
#    Schedule.find(productId : productId)

#  if designerIds
#    query = _.extend  query,
#      $or: [
#        'profile.designerName':
#          $regex : searchText
#      ,

  'product.schedules' : (productId, designerId) ->
    Sales.find
      $or:[
        productId : productId
      ,
        designerId : designerId
        type : 'holiday'

    ]

#########################
# event / tags
#########################

#  'designer.tags': (designerId) ->
#    selector =
#      isActive: true
#      isVisible: true
#      designerId: designerId
#    options =
#      sort :
#        registerCount : -1
#        clickCount : -1
#    Tags.find selector, options

  'tags.cloud': ->
    selector =
#      isRecommend: true
      isActive: true
      isVisible: true
    options =
      limit : 50
      sort :
        registerCount : -1
        clickCount : -1
    result = Tags.find selector, options
    return result

  'events' : ->
    Events.find
      isActive : true
      isVisible : true

#########################
# reviews
#########################

#  'product.reviews': (productId) ->
#    Reviews.find
#      productId : productId
#      isActive : true
#      isVisible : true

#########################
# user / designers
#########################

  'user' : ( userId ) ->
    Meteor.users.find( userId )

  'designers.otherDesigners': ( designerId ) ->
    designer = Meteor.users.findOne designerId
    tags = designer.profile.tags

    selector =
      'profile.isActive': true
      'profile.isApproved': true
      'profile.tags' :
        $in : tags
    options =
      limit : 5
      sort :
        createdAt : -1
    Meteor.users.find selector, options

  'designers': (searchText) ->
    query =
      'profile.isApproved' : true
      'profile.isActive' : true
#      'profile.designerName' :
#        $exists: true
    if searchText
      portfolios = Portfolios.find
        isActive: true
        isVisible: true
        title:
          $regex : searchText
      designerIds = portfolios.map (portfolio)->
        return portfolio.designerId

      if designerIds
        query = _.extend  query,
          $or: [
            'profile.designerName':
              $regex : searchText
          ,
            'profile.simpleInfo':
              $regex : searchText
          ,
            'profile.detailInfo':
              $regex : searchText
          ,
            'profile.specialty':
              $regex : searchText
          ,
            'profile.sido':
              $regex : searchText
          ,
            'profile.gugun':
              $regex : searchText
          ,
            _id:
              $in : designerIds
          ]
      else
        query = _.extend  query,
          $or: [
            'profile.designerName':
              $regex : searchText
          ,
            'profile.simpleInfo':
              $regex : searchText
          ,
            'profile.detailInfo':
              $regex : searchText
          ,
            'profile.specialty':
              $regex : searchText
          ,
            'profile.sido':
              $regex : searchText
          ,
            'profile.gugun':
              $regex : searchText
          ]
    options =
      sort:
        createdAt: -1
    Meteor.users.find( query, options )

Meteor.publishComposite 'designer', (designerId) ->
  find: ->
    result = Meteor.users.find
      _id : designerId
      'profile.isActive' : true
    return result
  children: [
    find: (designer) ->
      Portfolios.find
        designerId : designer._id
        isActive : true
        isVisible : true
  ]

#########################
# portfolios
#########################

Meteor.publishComposite 'portfolios', (tag, searchText, searchDate) ->
  find: ->
    query =
      isActive: true
      isVisible: true
    if tag
      query.tags = tag

    if searchDate
      searchDate = moment(moment(searchDate).utc().format('YYYY-MM-DD')).add(1, 'days').toDate()
      schedules = Sales.find
        effectiveDays : searchDate

      dangerPortfolioId = []
      holiday = []
      schedules.forEach (schedule) ->
        if schedule.portfolioId
          dangerPortfolioId.push schedule.portfolioId
        if schedule.type is 'holiday'
          portfolios = Portfolios.find
            designerId : schedule.designerId
            isActive : true
            isVisible : true
          portfolios.forEach (portfolio) ->
            holiday.push portfolio._id

      safePortfolio = Portfolios.find
        isActive: true
        isVisible: true
        _id :
          $nin : dangerPortfolioId.concat(holiday)

      portfolioIds = new Set()
      safePortfolio.forEach (safe) ->
        portfolioIds.add safe._id

      i = 0
      while i < dangerPortfolioId.length
        products = Products.find
          portfolioId : dangerPortfolioId[i]

        products.forEach (product) ->
          possibleWorkPerDay = product.possibleWorkPerDay
          result = {}
          dangerPortfolioId.sort()
          for value of dangerPortfolioId
            index = dangerPortfolioId[value]
            result[index] = if result[index] == undefined then 1 else (result[index] += 1)
          for value of result
            if value is dangerPortfolioId[i] and result[value] < possibleWorkPerDay
              portfolioIds.add dangerPortfolioId[i]
        i++

      query = _.extend  query,
        _id:
          $in : Array.from(portfolioIds)

    if searchText
      designers = Meteor.users.find
        'profile.isApproved' : true
        'profile.isActive' : true
        'profile.designerName' :
          $regex : searchText
#          $regex : '/^qwe/'
      designerIds = designers.map (designer)->
        return designer._id

      if designerIds
        query = _.extend  query,
          $or: [
            designerId:
              $in : designerIds
          ,
            title:
              $regex : searchText
          ,
            sido:
              $regex : searchText
          ,
            gugun:
              $regex : searchText
          ,
            simpleInfo:
              $regex : searchText
          ,
            detailInfo:
              $regex : searchText
          ,
            workedYear:
              $regex : searchText
          ,
            workedMonth:
              $regex : searchText
          ,
            workedDay:
              $regex : searchText
          ,
            tags:
              $regex : searchText
          ]
      else
        query = _.extend  query,
          $or : [
            title:
              $regex : searchText
          ,
            sido:
              $regex : searchText
          ,
            gugun:
              $regex : searchText
          ,
            simpleInfo:
              $regex : searchText
          ,
            detailInfo:
              $regex : searchText
          ,
            workedYear:
              $regex : searchText
          ,
            workedMonth:
              $regex : searchText
          ,
            workedDay:
              $regex : searchText
          ,
            tags:
              $regex : searchText
          ]
#      console.log 'designerIds: ', designerIds
#      if designerIds
#        query1 = _.extend  query,
#          $or: [
#            designerId:
#              $in : designerIds
#          ]

    options =
      sort:
        createdAt: -1
    result = Portfolios.find( query, options )

#    schedule = []
#
#    result.forEach (portfolio) ->
#      products = Products.find(portfolioId : portfolio._id)
#      products.forEach (product) ->
#        schedules = Schedule.find(product._id)
#        schedules.forEach (schedule) ->
#          console.log typeof schedule.effectiveDays

    return result
  children: [
    find: (portfolios) ->
      Meteor.users.find portfolios.designerId
  ]

Meteor.publishComposite 'portfolio', (portfolioId) ->
  find: ->
    result = Portfolios.find portfolioId
    return result
  children: [
    find: (portfolio) ->
      Meteor.users.find portfolio.designerId
  ,
    find: (portfolio) ->
      Products.find
        portfolioId : portfolio._id
        isActive: true
        isVisible: true
  ]


Meteor.publishComposite 'portfolios.mine', (searchText, searchDate, tag) ->
  find: ->
    query =
      isActive: true
      isVisible: true
      likeUserIds : @userId

    if tag
      query.tags = tag

    if searchDate
      searchDate = moment(moment(searchDate).utc().format('YYYY-MM-DD')).add(1, 'days').toDate()
      schedules = Sales.find
        effectiveDays : searchDate

      dangerPortfolioId = []
      holiday = []
      schedules.forEach (schedule) ->
        if schedule.portfolioId
          dangerPortfolioId.push schedule.portfolioId
        if schedule.type is 'holiday'
          portfolios = Portfolios.find
            designerId : schedule.designerId
            isActive : true
            isVisible : true
          portfolios.forEach (portfolio) ->
            holiday.push portfolio._id

      safePortfolio = Portfolios.find
        isActive: true
        isVisible: true
        _id :
          $nin : dangerPortfolioId.concat(holiday)

      portfolioIds = new Set()
      safePortfolio.forEach (safe) ->
        portfolioIds.add safe._id

      i = 0
      while i < dangerPortfolioId.length
        products = Products.find
          portfolioId : dangerPortfolioId[i]

        products.forEach (product) ->
          possibleWorkPerDay = product.possibleWorkPerDay
          result = {}
          dangerPortfolioId.sort()
          for value of dangerPortfolioId
            index = dangerPortfolioId[value]
            result[index] = if result[index] == undefined then 1 else (result[index] += 1)
          for value of result
            if value is dangerPortfolioId[i] and result[value] < possibleWorkPerDay
              portfolioIds.add dangerPortfolioId[i]
        i++

      query = _.extend  query,
        _id:
          $in : Array.from(portfolioIds)

    if searchText
      designers = Meteor.users.find
        'profile.isApproved' : true
        'profile.isActive' : true
        'profile.designerName' :
          $regex : searchText
      #          $regex : '/^qwe/'
      console.log  'count : ', designers.count()
      designerIds = designers.map (designer)->
        return designer._id

      if designerIds
        query = _.extend  query,
          $or: [
            designerId:
              $in : designerIds
          ,
            title:
              $regex : searchText
          ,
            sido:
              $regex : searchText
          ,
            gugun:
              $regex : searchText
          ,
            simpleInfo:
              $regex : searchText
          ,
            detailInfo:
              $regex : searchText
          ,
            workedYear:
              $regex : searchText
          ,
            workedMonth:
              $regex : searchText
          ,
            workedDay:
              $regex : searchText
          ,
            tags:
              $regex : searchText
          ]
      else
        query = _.extend  query,
          $or : [
            title:
              $regex : searchText
          ,
            sido:
              $regex : searchText
          ,
            gugun:
              $regex : searchText
          ,
            simpleInfo:
              $regex : searchText
          ,
            detailInfo:
              $regex : searchText
          ,
            workedYear:
              $regex : searchText
          ,
            workedMonth:
              $regex : searchText
          ,
            workedDay:
              $regex : searchText
          ,
            tags:
              $regex : searchText
          ]

    options =
      sort:
        createdAt: -1
    result = Portfolios.find( query, options )
    return result
  children: [
    find: (portfolios) ->
      Meteor.users.find portfolios.designerId
  ]

#########################
# product
#########################

Meteor.publishComposite 'product', (productId) ->
  find: ->
    result = Products.find( _id : productId )
    return result
  children: [
    find: (product) ->
      Portfolios.find( _id : product.portfolioId )
  ,
    find: (product) ->
      Meteor.users.find( _id : product.designerId )
  ]

#########################
# QNA
#########################

Meteor.publishComposite 'qnas.user', (userId) ->
  find: ->
    result = Qnas.find(userId : userId)
    return result
  children: [
    find: (qnas) ->
      Meteor.users.find( _id : qnas.designerId )
  ,
    find: (qnas) ->
      Portfolios.find( _id : qnas.portfolioId )
  ]

#########################
# order
#########################

Meteor.publishComposite 'sales', (userId) ->
  find: ->
    result = Sales.find(userId : userId)
    return result
  children: [
    find: (sales) ->
      Portfolios.find( _id : sales.portfolioId  )
  ,
    find: (sales) ->
      Meteor.users.find( _id : sales.designerId )
  ,
    find: (sales) ->
      Products.find( _id : sales.productId )
  ,
    find: (sales) ->
      Reviews.find( saleId : sales._id )
  ]

#########################
# review
#########################

Meteor.publishComposite 'product.reviews', (productId) ->
  console.log 'productId : ', productId
  find: ->
    result = Reviews.find
      productId : productId
      isActive : true
      isVisible : true
    return result
  children: [
    find: (reviews) ->
      Meteor.users.find(_id : reviews.userId)
  ]

Meteor.publishComposite 'portfolio.reviews', (portfolioId) ->
  find: ->
    result = Reviews.find
      portfolioId : portfolioId
      isActive : true
      isVisible : true
    return result
  children: [
    find: (reviews) ->
      Meteor.users.find(_id : reviews.userId)
  ]

Meteor.publishComposite 'designer.reviews', (designerId) ->
  find: ->
    result = Reviews.find
      designerId : designerId
      isActive : true
      isVisible : true
    return result
  children: [
    find: (reviews) ->
      Meteor.users.find(_id : reviews.userId)
  ]

Meteor.publishComposite 'main.slider', ->
  find: ->
    result = Reviews.find
      score:
        $gte: 8
      'isActive' : true
    return result
  children: [
    find: (reviews) ->
      Meteor.users.find(reviews.designerId)
  ,
    find: (reviews) ->
      Portfolios.find(reviews.portfolioId)
  ]
