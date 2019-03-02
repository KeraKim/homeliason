require './A400_designers.tpl.jade'

Template.A400_designers.onCreated ->
  @subscribe 'tags.cloud'
  @moreViewCount = new ReactiveVar(1)
  @selectOption = new ReactiveVar '최신순'
  @initFlag = new ReactiveVar false

Template.A400_designers.onRendered ->

  @autorun =>
    if @subscriptionsReady()
      designers = Meteor.users.find
        'profile.isApproved' : true
        'profile.isActive' : true
        'profile.isWriteProfile' : true
      unless designers
        return
      if @moreViewCount.get() * 10 > designers.count()
        $('.more-btn-box').hide()

  @autorun =>
    searchText = FlowRouter.getQueryParam('searchText')
    @subscribe 'designers', searchText

  mr_firstSectionHeight = undefined

  initializeMasonry = ->
    $('.masonry').each ->
      container = $(this).get(0)
      $(container).imagesLoaded().progress ->
        msnry = new Masonry(container, itemSelector: '.masonry-item')
        msnry.on 'layoutComplete', ->
          mr_firstSectionHeight = $('.main-container section:nth-of-type(1)').outerHeight(true)
          # Fix floating project filters to bottom of projects container
          $('.masonry').addClass 'fadeIn'
          if $('.masonryFlyIn').length
            masonryFlyIn()
          return
        msnry.layout()

  masonryFlyIn = ->
    $items = $('.masonryFlyIn .masonry-item:not(.fadeIn)')
    time = 0
    $items.each ->
      item = $(this)
      setTimeout (->
        item.addClass 'fadeIn'
        return
      ), time
      time += 200

  @autorun =>
    if @initFlag.get() and @selectOption.get()
      if @subscriptionsReady()
        Tracker.afterFlush =>
          Meteor.setTimeout ->
            container = $('.masonry').get(0)
            rmsnry = new Masonry(container, itemSelector: '.masonry-item')
            rmsnry.destroy()
            initializeMasonry()
          , 1000

  @autorun =>
    @moreViewCount.get()
    if @subscriptionsReady()
      Tracker.afterFlush =>
        Meteor.setTimeout ->
          initializeMasonry()
          $('.masonry-loader').addClass 'fadeOut'
        , 1000

  mr_firstSectionHeight = $('.main-container section:nth-of-type(1)').outerHeight(true);

  @autorun =>
    #태그 클라우드 설정 부분
    if @subscriptionsReady()
      Tracker.afterFlush =>
        Meteor.setTimeout ->
          $('#myCanvas').tagcanvas({
            textFont: null
            textColour: null
            weightMode:'both'
            weight: true
            weightGradient: {
              0:    '#00B86F',
              0.33: '#00B86F',
              0.66: '#00B86F',
              1:    '#00B86F'
            }
            initial : [0.3, 0.3]
            textColour: '#00B86F'
            depth: 0.1
            maxSpeed: 0.005
            wheelZoom : false
            shape : 'sphere'
            outlineColour : '#FFFFFF'
            decel : 1
            textHeight : 30
            outlineColour : '#00FF00'
            outlineRadius : 5
            reverse : true
          }, 'tags')
        , 1000

  $( ".datePicker" ).datepicker
    onSelect: (dateText) ->
      FlowRouter.go 'portfolios', {}, {searchDate : dateText}

Template.A400_designers.events
  'click .designer' : (e, t) ->
    designerId = Blaze.getData(e.target)._id
    Meteor.call 'designer.update.viewCount', designerId, (error, result)->
      if error
        console.log error
      else
         FlowRouter.go 'designer', {designerId : designerId}

  'click .cloudTag': (e, t) ->
    e.preventDefault()
    tag = Blaze.getData(e.target)
    Meteor.call 'tag.click.id', tag._id ,(error) ->
      if error
        console.log error
      else
        console.log tag.tagName
        FlowRouter.go 'portfolios', {}, {tag : tag.tagName}

  'click .more-btn' : (e, t) ->
    count = t.moreViewCount.get()
    count += 1
    t.moreViewCount.set count
    $('.masonry-loader').removeClass 'fadeOut'

#  'keyup .search-input': (e, t) ->
#    if e.keyCode is 13
#      FlowRouter.setQueryParams
#        searchText : $('.search-input').val()
  'keyup .search-input': (e, t) ->
    searchText = ''
    if $('.pc-search-input').val() isnt ''
      searchText = $('.pc-search-input').val()
    if $('.mobile-search-input').val() isnt ''
      searchText = $('.mobile-search-input').val()
    if e.keyCode is 13
      FlowRouter.setQueryParams
        searchText : searchText

  'change #filter-select': (e, t) ->
    t.initFlag.set true
    t.selectOption.set $('#filter-select').val()

Template.A400_designers.helpers
  designers : ->
#    Meteor.users.find
#      'profile.isApproved' : true
#      'profile.isActive' : true

    sort = createdAt: -1
    selectOption = Template.instance().selectOption.get()
    if selectOption is '최신순'
      sort = createdAt: -1
      console.log '최신순'
    else if selectOption is '조회순'
      sort = 'profile.viewCount': -1
      console.log '조회'
    else if selectOption is '별점순'
      sort = 'profile.reviewScore': -1
      console.log '별점'
    selector =
      'profile.isApproved' : true
      'profile.isActive' : true
      'profile.isWriteProfile' : true
    options =
      limit : Template.instance().moreViewCount.get() * 10
      sort:
        sort
    Meteor.users.find selector, options

  careerYear : (text) ->
    if text isnt '0'
      text + '년'
    else
      ''

  careerMonth : (text) ->
    if text isnt '0'
      text + '개월'
    else
        ''

  tags: ->
    selector =
#      isRecommend: true
      isActive: true
      isVisible: true
    options =
      limit : 20
      sort :
        registerCount : -1
        clickCount : -1
    Tags.find selector, options

  recommendTag : ->
    selector =
      isRecommend: true
      isActive: true
      isVisible: true
    options =
      limit : 5
    Tags.find selector, options

  searchText: ->
    FlowRouter.getQueryParam('searchText')

  popularTags: ->
    selector =
      isActive: true
      isVisible: true
    options =
      limit : 5
      sort :
        clickCount : -1
    Tags.find selector, options

  highScoreTags: ->
    selector =
      isActive: true
      isVisible: true
    options =
      limit : 5
      sort :
        score : -1
    Tags.find selector, options

  averageScore: (designerId) ->
    reviews = Reviews.find
      designerId : designerId

    unless  reviews
      return

    sum = 0
    reviews.map (review)->
      sum += review.score
    if reviews.count() is 0
      0
    else
      avg = sum / reviews.count()
      Math.round(avg)

#  tagSize: (tagId) ->
#    tag = Tags.findOne(tagId)
#    size = 1
#    size += (tag.registerCount * 0.05)
#    if tag.isRecommend
#      size += 0.1
#    size += parseInt(tag.clickCount / 30)
#    size

  tagSize: (tagId) ->
    tag = Tags.findOne(tagId)
    size = 2
    size += (tag.registerCount * 0.01)
    if tag.isRecommend
      size += 0.5
    size += parseInt(tag.clickCount / 1000)
    if size > 4
      size = 4
    size

  productCount: (productCount) ->
    if productCount is 0
      '상품 없음'
    else
      '상품 ' + productCount + '개'