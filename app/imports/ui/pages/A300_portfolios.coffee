require './A300_portfolios.tpl.jade'

Template.A300_portfolios.onCreated ->
#  @subscribe 'portfolios'
  @subscribe 'tags.cloud'
  @moreViewCount = new ReactiveVar(1)
  @selectOption = new ReactiveVar '최신순'
  @initFlag = new ReactiveVar false
  @portfolioId = new ReactiveVar ''
  @designerId =  new ReactiveVar ''

Template.A300_portfolios.onRendered ->

  @autorun =>
    if @subscriptionsReady()
      portfolios = Portfolios.find
        isActive: true
        isVisible: true
      unless portfolios
        return
      if @moreViewCount.get() * 10 > portfolios.count()
        $('.more-btn-box').hide()

  @autorun =>
    if @subscriptionsReady()
      Tracker.afterFlush =>
        SocialShareKit.init
          forceInit: true

  @autorun =>
    tag = FlowRouter.getQueryParam('tag')
    searchText = FlowRouter.getQueryParam('searchText')
    searchDate = FlowRouter.getQueryParam('searchDate')
    @subscribe 'portfolios',tag ,searchText, searchDate

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

#    $('.masonry').each ->
#      container = $(this).get(0)
#      msnry = new Masonry(container, itemSelector: '.masonry-item')
#      msnry.on 'layoutComplete', ->
#        mr_firstSectionHeight = $('.main-container section:nth-of-type(1)').outerHeight(true)
#        # Fix floating project filters to bottom of projects container
#        $('.masonry').addClass 'fadeIn'
#        if $('.masonryFlyIn').length
#          masonryFlyIn()
#        return
#      msnry.layout()

  masonryFlyIn = ->
    $items = $('.masonryFlyIn .masonry-item:not(.fadeIn)')
    time = 0
    $items.each ->
      item = $(this)
      Meteor.setTimeout ->
        item.addClass 'fadeIn'
        return
      , time
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
      FlowRouter.setQueryParams
        searchDate : dateText

  @autorun =>
    if @subscriptionsReady()
      Tracker.afterFlush =>
        if FlowRouter.getQueryParam('searchDate')
          $( ".datePicker" ).datepicker 'setDate' , FlowRouter.getQueryParam('searchDate')

Template.A300_portfolios.events

  'click .custom-btn.share-btn': (e, t) ->
    $share = $(e.currentTarget).closest('ul').siblings('.james.share')

    if $share.hasClass 'active'
      Meteor.setTimeout ->
        $share.toggleClass 'visible'
      , 500

    else
      $share.toggleClass 'visible'

    $share.toggleClass 'active'

  'click .portfolio-item' : (e, t) ->
    portfolioId = Blaze.getData(e.target)._id
    designerId = Blaze.getData(e.target).designerId

    Meteor.call 'portfolio.update.viewCount', portfolioId, (error, result)->
      if error
        console.log error
      else
        FlowRouter.go 'portfolio', {designerId : designerId, portfolioId : portfolioId}

  'click .likes-btn' : (e, t) ->
    e.preventDefault()

    unless Meteor.userId()
      sweetAlert "찜 하기", "찜하기는 로그인한 사용자만 가능합니다.", "warning"
      return

    portfolio = Blaze.getData(e.target)
    if portfolio.likeUserIds and Meteor.userId() in portfolio.likeUserIds
      Meteor.call 'portfolios.likes.remove', portfolio._id, (error, result)->
        if error
          console.log error
        else
          console.log 'success remove'
    else
      Meteor.call 'portfolios.likes.add', portfolio._id, (error, result)->
        if error
          console.log error
        else
          console.log 'success add'

  'click .cloudTag': (e, t) ->
    e.preventDefault()
    tag = Blaze.getData(e.target)
    Meteor.call 'tag.click.id', tag._id ,(error) ->
      if error
        console.log error
      else
        console.log 'success'
    FlowRouter.setQueryParams
      tag : tag.tagName

  'click .more-btn' : (e, t) ->
    count = t.moreViewCount.get()
    count += 1
    t.moreViewCount.set count
    $('.masonry-loader').removeClass 'fadeOut'

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

  'click .share-btn': (e, t) ->
    portfolio = Blaze.getData(e.target)
    t.portfolioId = portfolio._id
    t.designerId = portfolio.designerId

Template.A300_portfolios.helpers

  portfolios : ->
    sort = createdAt: -1
    selectOption = Template.instance().selectOption.get()
    if selectOption is '최신순'
      sort = createdAt: -1
    else if selectOption is '조회순'
      sort = viewCount: -1
    else if selectOption is '별점순'
      sort = reviewScore: -1
    selector =
      isActive: true
      isVisible: true
    options =
      limit : Template.instance().moreViewCount.get() * 10
      sort:
        sort
    Portfolios.find selector, options

  designer : ->
    Meteor.users.findOne(this.designerId)

  month : (text) ->
    if text is 'null'
      ''
    else if text?
        text + '월'

  day : (text) ->
    if text is 'null'
      ''
    else if text?
      text + '일'

  likeImage : (likeUserIds) ->
    unless likeUserIds
      return '/img/like-disable.png'

    if Meteor.userId() in likeUserIds
      '/img/like.png'
    else
      '/img/like-disable.png'

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

  tag: ->
    FlowRouter.getQueryParam('tag')

  searchText: ->
    FlowRouter.getQueryParam('searchText')

  createByHomeliason: (flag) ->
    if flag
      'create-by-homeliason'
    else
      ''

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

  productCount: (count) ->
    if count is 0
      '상품 없음'
    else
      '상품 ' + count + '개'