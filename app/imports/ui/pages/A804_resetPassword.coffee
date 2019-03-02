require './A804_resetPassword.tpl.jade'

Template.A804_resetPassword.onRendered ->

  $('#resetPassword-form').validate
    rules:
      password:
        required: true
        minlength: 8
      passwordCheck:
        equalTo: '#password'

    messages:
      password:
        required: '필수로입력하세요'
        minlength: '최소 {0}글자이상이어야 합니다'
      passwordCheck:
        equalTo: '비밀번호를 동일하게 입력해주세요.'

    errorPlacement: (error, element) ->
      $(element).closest('div').find('.error-text').html error

    submitHandler: (form, validator) ->

      Accounts.resetPassword FlowRouter.getParam('token'), $('#password').val(), (err) ->
        if err
          console.log err.reason
          sweetAlert "토큰 오류", "유효하지 않은 토큰 입니다.", "error"
        else
          FlowRouter.go 'index'
#          sweetAlert "비밀번호 변경", "비밀번호 변경에 성공하였습니다..", "success"


Template.A804_resetPassword.events

  'keyup #passwordCheck': (e, t) ->
    if e.keyCode is 13
      $('#submit-btn').trigger('click')

  'click #submit-btn' : (e, t) ->
    $('#resetPassword-form').submit()