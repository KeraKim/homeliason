require './A803_changePassword.tpl.jade'

Template.A803_changePassword.onCreated ->

Template.A803_changePassword.onRendered ->

  $('#password-form').validate
    rules:
      oldPassword:
        required: true
      newPassword:
        required: true
        minlength: 8
      checkPassword:
        equalTo: '#newPassword'

    messages:
      oldPassword:
        required: '현재 비밀번호를 입력해주세요'
      newPassword:
        required: '새로운 비밀번호를 입력해주세요'
        minlength: '8자리 이상으로 입력해주세요'
      checkPassword:
        equalTo: '새 비밀번호와 일치하지 않습니다.'

    errorPlacement: (error, element) ->
      $(element).closest('div').find('.error-text').html error

    submitHandler: (form, validator) ->
      oldPassword = $('#oldPassword').val()
      newPassword = $('#newPassword').val()

      Accounts.changePassword oldPassword, newPassword, (error) ->
        if error
          if error.reason.indexOf('Incorrect') > -1
            sweetAlert "비밀번호 변경 실패", "현재 비밀번호가 잘못 입력되었습니다.", "error"
        else
          sweetAlert "비밀번호 변경 성공", "비밀번호가 변경되었습니다.", "success"


Template.A803_changePassword.events

  'click #submit-btn' : (e, t) ->
    $('#password-form').submit()