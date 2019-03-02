require './editManager.tpl.jade'

Template.editManager.onCreated ->

Template.editManager.onRendered ->

  $('#manager-form').validate
    rules:
      userName:
        required: true
      email :
        required: true
        email: true
      password:
        required : true
        minlength: 8
      firstMobileNumber:
        required : true
        number : true
      meddleMobileNumber:
        required : true
        number : true
      lastMobileNumber:
        required : true
        number : true

    messages:
      userName:
        required : '필수 입력 사항입니다.'
      email :
        required : '필수 입력 사항입니다.'
        email: '이메일 형식에 어긋납니다.'
      password:
        required : '필수 입력 사항입니다.'
        minlength: '최소 {0}글자이상이어야 합니다'
      firstMobileNumber:
        required : '필수 입력 사항입니다.'
        number : '숫자만 입력해주세요'
      meddleMobileNumber:
        required : '필수 입력 사항입니다.'
        number : '숫자만 입력해주세요'
      lastMobileNumber:
        required : '필수 입력 사항입니다.'
        number : '숫자만 입력해주세요'

    submitHandler: (form, validator) ->
      designerId = ''
      if Meteor.user().profile.isManager
        designerId = Meteor.user().profile.designerId
      else
        designerId = Meteor.userId()

      managerInfo =
        email : $('#email').val()
        password : $('#password').val()
        profile :
          userName : $('#userName').val()
          firstMobileNumber : $('#firstMobileNumber').val()
          meddleMobileNumber : $('#meddleMobileNumber').val()
          lastMobileNumber : $('#lastMobileNumber').val()
          designerId : designerId
          isManager : true
          isActive: true
          createdAt : new Date()
          isAdmin : false
          isApproved : true

      Meteor.call 'users.managers.add', managerInfo, (error, result) ->
        if error
          if error.reason.indexOf('Email') > -1
            sweetAlert "회원가입 실패", "이미 사용중인 이메일 입니다", "error"
        else
          FlowRouter.go 'managers'
#      Accounts.createUser managerInfo, (error)->
#        if error
#          if error.reason.indexOf('Email') > -1
#            sweetAlert "회원가입 실패", "이미 사용중인 이메일 입니다", "error"
#        else
#          FlowRouter.go 'managers'


Template.editManager.events
  'click #submit-button': (e, t) ->
    $('#manager-form').submit()

Template.editManager.helpers

