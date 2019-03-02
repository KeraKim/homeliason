require './A100_index.tpl.jade'

Template.A100_index.onCreated ->
  @subscribe 'tags.cloud'
  @subscribe 'main.slider'
  @subscribe 'events'
  @reviews = new ReactiveVar ''

Template.A100_index.onRendered ->

  @autorun =>
    if @subscriptionsReady()
      Tracker.afterFlush =>
        events = Events.find
          isPopup : true
          isVisible : true
          isActive : true
        if events.count() >= 1
          $('.mainEvent_modal').toggleClass 'reveal-modal'
          $('.modal-screen').toggleClass 'reveal-modal'

      console.log "autorun event popup"
      $(window).trigger('resize').trigger 'scroll'

#      $(document).on 'wheel mousewheel scroll', '.foundry_modal, .modal-screen', (evt) ->
#        $(this).get(0).scrollTop += evt.originalEvent.deltaY
#        false

  @autorun =>
    reviews = Reviews.find
      score:
        $gte: 8
      isActive : true
    unless reviews
      return
    @reviews.set reviews

    console.log "autorun review"
    $(window).trigger('resize').trigger 'scroll'


  Tracker.afterFlush =>
    $('.parallax1').parallax imageSrc: '/img/a-100-main-pic-1@2x.png'
    console.log "afterFlush parallax"

  @autorun =>
    #태그 클라우드 설정 부분
    if @subscriptionsReady()
      Tracker.afterFlush =>

#        $('.parallax1').parallax imageSrc: '/img/a-100-main-pic-1@2x.jpg'

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

      console.log "autorun tagCloud"
      $(window).trigger('resize').trigger 'scroll'

  #스와이프 설정 부분
  @autorun =>
    if @subscriptionsReady()
      Tracker.afterFlush =>
        Meteor.setTimeout ->
          new Swiper('.swiper-container',
            pagination: '.swiper-pagination'
            paginationClickable: true
            slidesPerView: 1
            loop: true
            nextButton: '.swiper-button-next'
            prevButton: '.swiper-button-prev')
        , 2000

      console.log "autorun swiper"
      $(window).trigger('resize').trigger 'scroll'

  #parallax 스크롤 설정 부분
  Meteor.setTimeout ->
    $('.parallax1').addClass 'fadeIn'
    console.log "setTimeout addClass"
    $(window).trigger('resize').trigger 'scroll'
  , 1000

#  @autorun =>
#    Tracker.afterFlush =>
#      $('.parallax1').parallax imageSrc: '/img/background7.jpg'

Template.A100_index.onDestroyed ->
  $('.parallax-mirror').remove()

Template.A100_index.events
  'click .down-button': (e, t) ->
    offset = $('.tag-square').offset()
    $('html, body').animate { scrollTop: offset.top }, 400

  'click .portfolio-btn': (e, t) ->
    FlowRouter.go 'portfolios'

  'click .designer-btn': (e, t) ->
    FlowRouter.go 'designers'

  'click .cloudTag': (e, t) ->
    e.preventDefault()
    tag = Blaze.getData(e.target)
    console.log tag.tagName
    Meteor.call 'tag.click.id', tag._id ,(error) ->
      if error
        console.log error
      else
        console.log 'success'
    FlowRouter.go 'portfolios', {},
      tag : tag.tagName

  'click .mainSliderImage': (e, t) ->
    review = Blaze.getData(e.target)
    FlowRouter.go 'portfolio', {designerId : review.designerId, portfolioId : review.portfolioId}

  'click .designerImage': (e, t) ->
    review = Blaze.getData(e.target)
    FlowRouter.go 'designer', {designerId : review.designerId}

Template.A100_index.helpers

  events: ->
    Events.find
      isPopup : true
      isVisible : true
      isActive : true

  tags: ->
    selector =
#      isRecommend: true
      isActive: true
      isVisible: true
    options =
      limit : 50
      sort :
        registerCount : -1
        clickCount : -1
    if document.body.clientWidth <= 786
      options.limit = 20

    Tags.find selector, options

  reviews: ->
    Template.instance().reviews.get()
#    reviews = Reviews.find
#      score:
#        $gte: 8
#      isActive : true
#    unless reviews
#      return
#    reviews

  portfolioImage: (portfolioId) ->
    portfolio = Portfolios.findOne portfolioId
    unless portfolio
      return
    portfolio.imageUrl[0]

  designerImage: (designerId) ->
    designer = Meteor.users.findOne designerId
    unless designer
      return
    designer.profile.designerSquareImageUrl

  designerName: (designerId) ->
    designer = Meteor.users.findOne designerId
    unless designer
      return
    designer.profile.designerName

  companyName: (designerId) ->
    designer = Meteor.users.findOne designerId
    unless designer
      return
    designer.profile.companyName

  starCSS : (num, starScore) ->
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
  tagSize: (tagId) ->
    tag = Tags.findOne(tagId)
    size = 0.5
    size += (tag.registerCount * 0.01)
    if tag.isRecommend
      size += 0.5
    size += parseInt(tag.clickCount / 1000)
    if size > 4
      size = 4
    if document.body.clientWidth <= 786
      size += 1.5
    size




