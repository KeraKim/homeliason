require './A801_findPassword.tpl.jade'

Template.A801_findPassword.onCreated ->

Template.A801_findPassword.onRendered ->

  $('#email-form').validate
    rules:
      email:
        required: true
        email: true

    messages:
      email:
        required: '이메일을 입력해주세요.'
        email: '이메일 형식에 어긋납니다.'

    errorPlacement: (error, element) ->
      $(element).closest('div').find('.error-text').html error

    submitHandler: (form, validator) ->
      Accounts.forgotPassword
        email : $('#email').val()
      , (err) ->
        if err
          if err.message is "User not found [403]"
            sweetAlert "이메일 찾기 실패", "가입되지 않은 이메일 입니다.", "error"
        else
          sweetAlert "메일 발송", "입력된 이메일 주소를 확인해주세요.", "success"


Template.A801_findPassword.events

  'click #submit-btn' : (e, t) ->
    $('#email-form').submit()