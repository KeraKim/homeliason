require './A301_portfolio.tpl.jade'

{ Page } = require '/imports/api/client/common.coffee'

Template.A301_portfolio.onCreated ->

  @portfolioId = FlowRouter.getParam 'portfolioId'
  @designerId = FlowRouter.getParam 'designerId'
  @portfolio = new ReactiveVar()
  @designer = new ReactiveVar()
  @products = new ReactiveVar()
  @tagWidth = new ReactiveVar(1150)

  @subscribe 'portfolio', @portfolioId
  @subscribe 'portfolio.reviews', @portfolioId

Template.A301_portfolio.onRendered ->

  @autorun =>
    if @subscriptionsReady()
      Tracker.afterFlush =>
        SocialShareKit.init forceInit: true

  @autorun =>
    portfolio =  Portfolios.findOne @portfolioId
    @portfolio.set portfolio
    @designer.set Meteor.users.findOne @designerId
    @products.set Products.find( portfolioId : @portfolioId )

  @autorun =>
    if @subscriptionsReady()
      $('.tag-button, .tagMore-btn').remove()
      sum = 0
      portfolio = @portfolio.get()
      $.each portfolio.tags, (index, item) ->
        $('.height80Box').append('<div class="btn-rounded tag-button">'+item+'</div>')
        sum += $('.tag-button').last().width() + 30
        if sum > Template.instance().tagWidth.get()
          $('.height80Box').append('<div class="btn-rounded tagMore-btn">+더보기</div>')
          return false

  @autorun =>
    if @subscriptionsReady()
      Tracker.afterFlush =>
        galleryTop = new Swiper('.gallery-top',
          spaceBetween: 10
        )
        galleryThumbs = new Swiper('.gallery-thumbs',
          spaceBetween: 10
          centeredSlides: true
          slidesPerView: 4
          touchRatio: 0.2
          slideToClickedSlide: true
        )

        galleryTop.params.control = galleryThumbs
        galleryThumbs.params.control = galleryTop

        imageUrls = @portfolio.get().imageUrl
        imageUrls.forEach (imageUrl, index) ->
          image = new Image
          image.src = imageUrl

          image.onload = ->
            if @width > @height
              $('.swiper-image:eq('+index+')').css('width', '100%')
              $('.swiper-image:eq('+index+')').css('height', 'auto')
            else
              $('.swiper-image:eq('+index+')').css('width', 'auto');
              $('.swiper-image:eq('+index+')').css('height', '100%');

            $('.image-cover:eq('+index+')').css('width', $('.swiper-image:eq('+index+')').width())
            $('.image-cover:eq('+index+')').css('height', $('.swiper-image:eq('+index+')').height())


  @autorun =>
    $('.portfolioQna-form').validate
      rules:
        title :
          required: true
        content:
          required: true
        email:
          required: true
          email: true
      messages:
        title :
          required: '제목을 입력해 주세요'
        content:
          required: '본문 내용을 입력해 주세요'
        email:
          required: '이메일을 입력해주세요'
          email: '메일 형식에 맞지않습니다.'

      errorPlacement: (error, element) ->
        $(element).closest('div').find('.error-text').html error

      submitHandler: (form, validator) ->

        portfolio = Template.instance().portfolio.get()

        userName = '비회원'
        if Meteor.user()
          userName = Meteor.user().profile.userName
        portfolioTitle = portfolio.title
        designer = Template.instance().designer.get()
        designerName = designer.profile.designerName
        designerEmail = designer.emails[0].address
        firstMobileNumber = designer.profile.firstMobileNumber
        meddleMobileNumber = designer.profile.meddleMobileNumber
        lastMobileNumber = designer.profile.lastMobileNumber
        mobile = firstMobileNumber.concat(meddleMobileNumber, lastMobileNumber)

        qna =
          title : $('.qna-title').val()
          content : $('.qna-content').val()
          email : $('.qna-email').val()
          type : '디자이너 문의'
          portfolioId : Template.instance().portfolioId
          designerId : Template.instance().designerId

        Meteor.call 'qnas.insert', qna, (error, result)->
          if error
            console.log error
          else
            $('.qna-title').val('')
            $('.qna-content').val('')
            sweetAlert '문의작성 완료', '문의내용이 저장되었습니다.', 'success'

        #문자로 디자이너에게 문의온걸 알려줌
        concatMessage1 = '[홈리에종]\n '
        concatMessage2 = '포트폴리오에 대한 고객님의 문의가 접수되었습니다. 홈리에종 디자이너 페이지의 모니터링-문의관리에서 답변해주시면 됩니다 :) http://home-liaison.com'
        Meteor.call 'aligo', concatMessage1.concat(portfolioTitle, concatMessage2), mobile, (error, result)->
          if error
            console.log error
          else
            console.log result
        #메일로 디자이너에게 문의온걸 알려줌
        designerMailDateObject = {
          templateName : '[홈리에종] 고객님의 문의사항이 접수되었습니다.',
          content1 : portfolioTitle,
          content2 : userName
        }
        Meteor.call 'mandrill', designerEmail, designerName, '[홈리에종] '+portfolioTitle+' 포트폴리오에 대한 '+userName+' 고객님의 문의가 접수되었습니다. 홈페이지를 통해 답변 해주세요.', designerMailDateObject, (error, result) ->
          if error
            console.log error
          else
            console.log result
        #메일로 사용자에게 문의가 접수되었다 알려줌
        userMailDateObject = {
          templateName : '[홈리에종] 디자이너에게 문의사항이 접수되었습니다.',
          content1 : designerName
        }
        Meteor.call 'mandrill', qna.email, '홈리에종 사용자님', '[홈리에종] '+designerName+' 디자이너에게 문의가 접수되었습니다. 빠른 시간 내에 답변 드리겠습니다.', userMailDateObject, (error, result) ->
          if error
            console.log error
          else
            console.log '사용자에게 메일 발송 성공'

Template.A301_portfolio.events

  'click .tabs li' : (e, t) ->
    tabName = $(e.currentTarget).attr('name')
    $('.active').removeClass('active')
    $('li[name="'+tabName+'"]').addClass('active')

  'click .tagMore-btn': (e, t) ->
    tagWidth = t.tagWidth.get()
    t.tagWidth.set tagWidth + 750

  'click .tag-button': (e, t) ->
#    tag = Blaze.getData(e.target)
    tag = $(e.currentTarget).text()
    console.log 'tag : ', tag
    Meteor.call 'tag.click.name', tag ,(error) ->
      if error
        console.log error
      else
        console.log 'success'
    FlowRouter.go 'portfolios', {}, {tag : tag}

  'click .custom-btn.share-btn': (e, t) ->
    $share = $(e.currentTarget).closest('.col-sm-12').find('.james.share')

    if $share.hasClass 'active'
      Meteor.setTimeout ->
        $share.toggleClass 'visible'
      , 500

    else
      $share.toggleClass 'visible'

    $share.toggleClass 'active'

  'click .tag-btn': (e, t) ->
    tag = Blaze.getData(e.target)
    Meteor.call 'tag.click.name', tag ,(error) ->
      if error
        console.log error
      else
    FlowRouter.go 'portfolios', {},
      tag : tag

  'click .widget-profile' : (e, t) ->
    console.log t.designerId
    FlowRouter.go 'designer', {designerId : t.designerId}

  'click .product-btn' : (e, t) ->
    productId = Blaze.getData(e.target)._id
    FlowRouter.go 'product', {designerId : t.designerId, portfolioId : t.portfolioId, productId: productId}

  'click #portfolioQna-btn' : (e, t) ->
    $('.portfolioQnaPopup').toggleClass 'reveal-modal'
    $('.modal-screen').toggleClass 'reveal-modal'

  'click .portfolioQnsSubmit-btn' : (e, t) ->
    $('.portfolioQna-form').submit()

  'click .likes-btn' : (e, t) ->
    e.preventDefault()

    unless Meteor.userId()
      sweetAlert "찜 하기", "찜하기는 로그인한 사용자만 가능합니다.", "warning"
      return

    portfolio = t.portfolio.get()
    if portfolio.likeUserIds and Meteor.userId() in portfolio.likeUserIds
      Meteor.call 'portfolios.likes.remove', portfolio._id, (error, result)->
        if error
          console.log error
        else
          console.log 'success add'
    else
      Meteor.call 'portfolios.likes.add', portfolio._id, (error, result)->
        if error
          console.log error
        else
          console.log 'success remove'


Template.A301_portfolio.helpers
  portfolio : ->
    Template.instance().portfolio.get()

  portfolioImage : ->
    portfolio = Template.instance().portfolio.get()
    if portfolio?
      portfolio.imageUrl

  designer : ->
    Template.instance().designer.get()

  products : ->
    Template.instance().products.get()

  likeImage : ->
    unless Template.instance().portfolio.get()
      return

    unless Template.instance().portfolio.get().likeUserIds
      return '/img/like-disable.png'

    if Meteor.userId() in Template.instance().portfolio.get().likeUserIds
      '/img/like.png'
    else
      '/img/like-disable.png'

  reviews : ->
    reviews = Reviews.find(portfolioId : Template.instance().portfolioId)
    unless  reviews
      return
    reviews

  userName : (userId) ->
    user = Meteor.users.findOne(userId)
    unless  user
      return
    user.profile.userName

  starCSS : (num, score) ->
    if score >= num
      'on'
    else

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

  createByHomeliason: () ->
    unless Template.instance().portfolio.get()
      return
    if Template.instance().portfolio.get().progressedByHomeLiaison
      'portfolio-create-by-homeliason'
    else
      ''
  comma: (price) ->
    Page.comma(price)

  dateFormat : (date) ->
    moment(date).format('YYYY-MM-DD')

  productName : (productId) ->
    product = Products.findOne productId
    unless product
      return

    product.title

#  tags : () ->
#    consoel.log Template.instance().portfolio.get().tags
#    Template.instance().portfolio.get().tags

