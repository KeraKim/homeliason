require './A800_login.tpl.jade'

{ bucket } = require '/imports/ui/pages/bucket.coffee'

Template.A800_login.onCreated ->

Template.A800_login.onRendered ->

  @autorun =>
    Tracker.afterFlush =>
      Meteor.setTimeout ->
        $('.parallax2').addClass 'fadeIn'
      , 700

  $('.parallax2').parallax imageSrc: '/img/background29.jpg'

  @autorun =>
    $('#login-from').validate
      rules:
        email:
          required: true
          email: true
        password:
          required: true
          minlength: 8
      messages:
        email:
          required: '필수로입력하세요'
          email: '메일 형식에 어긋납니다'
        password:
          required: '필수로입력하세요'
          minlength: '최소 {0}글자이상이어야 합니다'

      errorPlacement: (error, element) ->
        $(element).closest('div').find('.error-text').html error

      submitHandler: (form, validator) ->
        email = $('#email').val()
        password = $('#password').val()

        Meteor.loginWithPassword email, password, (error) ->
          if error
            sweetAlert "로그인 실패", "아이디와 비밀번호를 다시한번 확인해주세요", "error"
          else
            if bucket.get('designerId') and bucket.get('portfolioId') and bucket.get('productId')
              FlowRouter.go 'product', {designerId : bucket.get('designerId'), portfolioId : bucket.get('portfolioId'), productId: bucket.get('productId')}
            else
              FlowRouter.go 'index'

Template.A800_login.onDestroyed ->
  $('.parallax-mirror').remove()

Template.A800_login.events

  'keyup #password': (e, t) ->
    if e.which == 13
      $('#loginButton').trigger('click')

  'click #loginButton' : (e, t) ->
    $(e.currentTarget).parent('form').submit()

  'click #facebookButton': (e, t) ->
    Meteor.loginWithFacebook {}, (error) ->
      if error
        console.log 'error ', error

        if error?.reason is "Email already exists."
          # todo - 이메일 중복에 대해서만 처리할 것.
          sweetAlert "알림", "이미 이메일로 가입하셨습니다. 이메일 계정으로 로그인해 주세요", "error"
      else
#        FlowRouter.go 'index'
        if bucket.get('designerId') and bucket.get('portfolioId') and bucket.get('productId')
          FlowRouter.go 'product', {designerId : bucket.get('designerId'), portfolioId : bucket.get('portfolioId'), productId: bucket.get('productId')}
        else
          FlowRouter.go 'index'

  'click #forgotPasswordButton' : (e, t) ->
    FlowRouter.go 'findPassword'
