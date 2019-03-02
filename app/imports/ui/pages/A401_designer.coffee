require './A401_designer.tpl.jade'

Template.A401_designer.onCreated ->
#FlowRouter.getQueryParam('designerId')

#  @designerId = FlowRouter.getParam 'designerId'
  @moreViewCount = new ReactiveVar(1)
  @designerId = new ReactiveVar(FlowRouter.getParam 'designerId')
  @designer = new ReactiveVar ''
  @tagWidth = new ReactiveVar(960)
  @widgetCount = 0

Template.A401_designer.onRendered ->

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
    @subscribe 'designer', @designerId.get()
    @subscribe 'designer.reviews', @designerId.get()
    @subscribe 'designers.otherDesigners', @designerId.get()
    @designer.set Meteor.users.findOne @designerId.get()

  @autorun =>
    if @subscriptionsReady()
      $('.tag-button, .tagMore-btn').remove()
      sum = 0
      designer = @designer.get()
      $.each designer.profile.tags, (index, item) ->
        $('.height80Box').append('<div class="btn-rounded tag-button">'+item+'</div>')
        sum += $('.tag-button').last().width() + 30
        if sum > Template.instance().tagWidth.get()
          $('.height80Box').append('<div class="btn-rounded tagMore-btn">+더보기</div>')
          initializeMasonry()
          return false

  @autorun =>
    if @subscriptionsReady()
      Tracker.afterFlush =>
        SocialShareKit.init
          forceInit: true

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
    @moreViewCount.get()
    if @.subscriptionsReady()
      Tracker.afterFlush =>
        Meteor.setTimeout ->
          initializeMasonry()
          $('.masonry-loader').addClass 'fadeOut'
        , 500

  mr_firstSectionHeight = $('.main-container section:nth-of-type(1)').outerHeight(true);

Template.A401_designer.events

  'click .more-btn' : (e, t) ->
    count = t.moreViewCount.get()
    count += 1
    t.moreViewCount.set count
    $('.masonry-loader').removeClass 'fadeOut'

  'click .tagMore-btn': (e, t) ->
    tagWidth = t.tagWidth.get()
    t.tagWidth.set tagWidth + 300

  'click .custom-btn.share-btn': (e, t) ->
    $share = $(e.currentTarget).closest('ul').find('.james.share')

    if $share.hasClass 'active'
      Meteor.setTimeout ->
        $share.toggleClass 'visible'
      , 500

    else
      $share.toggleClass 'visible'

    $share.toggleClass 'active'

  'click .tag-button, click .sideTag-button': (e, t) ->
    tag = $(e.currentTarget).text()
    Meteor.call 'tag.click.name', tag ,(error) ->
      if error
        console.log error
      else
        console.log 'success'
    FlowRouter.go 'portfolios', {},
      tag : tag

  'click .portfolio-item' : (e, t) ->
    portfolioId = Blaze.getData(e.target)._id
    Meteor.call 'portfolio.update.viewCount', portfolioId, (error, result)->
      if error
        console.log error
      else
        FlowRouter.go 'portfolio', {designerId : t.designerId.get(), portfolioId : portfolioId}

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

  'click .widget-profile' : (e, t) ->
    designer = Blaze.getData(e.target)
#    FlowRouter.setParams designer._id
#    FlowRouter.go 'designer', {designerId : designer._id}
    t.designerId.set designer._id

  'click #more-btn' : (e, t) ->
    count = t.moreViewCount.get()
    count += 1
    t.moreViewCount.set count
    $('.masonry-loader').removeClass 'fadeOut'

Template.A401_designer.helpers
  designer : ->
#    Meteor.users.findOne( Template.instance().designerId.get() )
    designer = Template.instance().designer.get()
    unless designer
      return
    designer

#  portfolios : ->
#    portfolios = Portfolios.find( 'designerId' : Template.instance().designerId.get() )
#    unless portfolios
#      return
#    portfolios

  portfolios : ->
    selector =
      'designerId' : Template.instance().designerId.get()
      isActive: true
      isVisible: true
    options =
      limit : Template.instance().moreViewCount.get() * 10
      sort: createdAt: -1
    Portfolios.find selector, options

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

  averageScore: ->
    reviews = Reviews.find
      designerId : Template.instance().designerId
    sum = 0
    reviews.map (review)->
      sum += review.score
    if reviews.count() is 0
      0
    else
      avg = sum / reviews.count()
      Math.round(avg)

  otherAverageScore: (designerId) ->
    reviews = Reviews.find
      designerId : designerId
    sum = 0
    reviews.map (review)->
      sum += review.score
    if reviews.count() is 0
      0
    else
      avg = sum / reviews.count()
      Math.round(avg)

  otherDesigners: (tag) ->
    selector =
      'profile.isActive': true
      'profile.isApproved': true
      'profile.tags' : tag
      _id :
        $ne : Template.instance().designerId.get()
    options =
      limit : 3
      sort :
        createdAt : -1
    designers = Meteor.users.find selector, options
#    console.log '전 :', Template.instance().widgetCount
    Template.instance().widgetCount += designers.count()
#    console.log '후 :',  Template.instance().widgetCount
    designers

  designerTags : ->
    designer = Template.instance().designer.get()
    unless designer
      return
    tags = designer.profile.tags
    tagArray = []
    i = 0
    while  i < tags.length
      designers = Meteor.users.find
        'profile.tags' : tags[i]
        _id :
          $ne : Template.instance().designerId.get()
      if 0 < designers.count()
        tagArray.push tags[i]
      i++

    tagArray

  createByHomeliason: (flag) ->
    if flag
      'create-by-homeliason'
    else
      ''

  productCount: (count) ->
    if count is 0
      '상품 없음'
    else
      '상품 ' + count + '개'