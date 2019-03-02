require './A700_signup.tpl.jade'

Template.A700_signup.onRendered ->

  @autorun =>
    Tracker.afterFlush =>
      Meteor.setTimeout ->
        $('.parallax3').addClass 'fadeIn'
      , 700

  $('.parallax3').parallax imageSrc: '/img/background35.jpg'

  $('#signup-from').validate
    rules:
      name:
        required: true
      email:
        required: true
        email: true
      password:
        required: true
        minlength: 8
      passwordCheck:
        equalTo: '#password'
      checkbox1:
        required:
          depends: (element)->
            check1 = $('#checkbox1').is(':checked')
            if not check1
              sweetAlert "회원가입 실패", "필수 이용약관에 동의해 주세요", "error"
            return not check1
      checkbox2:
        required:
          depends: (element)->
            check2 = $('#checkbox2').is(':checked')
            if not check2
              sweetAlert "회원가입 실패", "필수 이용약관에 동의해 주세요", "error"
            return not check2
    messages:
      name:
        required: '필수로입력하세요'
      email:
        required: '필수로입력하세요'
        email: '메일 형식에 어긋납니다'
      password:
        required: '필수로입력하세요'
        minlength: '최소 {0}글자이상이어야 합니다'
      passwordCheck:
        equalTo: '비밀번호를 동일하게 입력해주세요.'

    errorPlacement: (error, element) ->
      $(element).closest('div').find('.error-text').html error

    submitHandler: (form, validator) ->
      user =
        email: $('#email').val()
        password: $('#password').val()
        profile:
          userName: $('#name').val()
          isDesigner : false

      Accounts.createUser user, (error)->
        if error
          if error.reason.indexOf('Email') > -1
            sweetAlert "회원가입 실패", "이미 사용중인 이메일 입니다", "error"
        else
#            FlowRouter.go 'index'
          mailDateObject = {
            templateName : '[홈리에종] 가입을 환영합니다!'
          }
          Meteor.call 'mandrill', user.email, user.profile.userName, '[홈리에종] 회원가입을 환영합니다.', mailDateObject, (error, result) ->
            if error
              console.log error
            else
              console.log result
          FlowRouter.go 'result', { pageName : 'sighup' }

Template.A700_signup.onDestroyed ->
  $('.parallax-mirror').remove()

Template.A700_signup.events

  #TODO 체크박스 처리하는 코드
  'click .checkbox-option' : (e, t) ->
    $(e.currentTarget).toggleClass 'checked'
    checkbox = $(e.currentTarget).find('input')
    if checkbox.prop('checked') == false
      checkbox.prop 'checked', true
    else
      checkbox.prop 'checked', false

  'click .terms-button': (e, t) ->
    FlowRouter.go 'terms'

  'click .forgotPassword-button': (e, t) ->
    FlowRouter.go 'findPassword'

  'click #signupButton' : (e, t) ->
    $(e.currentTarget).parent('form').submit()

  'click #facebookButton': (e, t) ->
    if $('#checkbox1').is(':checked') and $('#checkbox2').is(':checked')
      Meteor.loginWithFacebook {}, (error) ->
        if error
          console.log 'error ', error

          if error?.reason is "Email already exists."
            #todo - 이메일 중복에 대해서만 처리할 것.
            sweetAlert "알림", "이미 이메일로 가입하셨습니다. 이메일 계정으로 로그인해 주세요", "error"

        else
          FlowRouter.go 'index'
    else
      sweetAlert "회원가입 실패", "필수 이용약관에 동의해 주세요", "error"

