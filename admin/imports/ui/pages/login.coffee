require './login.tpl.jade'

{ FlowRouter } = require 'meteor/kadira:flow-router'

Template.login.events
  'click #login':(e, t)->
    e.preventDefault()

    email = $('#email').val()
    password = $('#password').val()

    Meteor.loginWithPassword email, password, (error)->
      if error
        console.log error
        swal "로그인 실패", "아이디와 비밀번호를 확인해주세요", "error"
      else
        $('#email').val('')
        $('#password').val('')
        user = Meteor.users.findOne 'emails.0.address' : email
        if user.profile.isActive is false
          swal "로그인 실패", "디자이너, 관리자만 로그인 가능합니다", "error"
        else
          if user.profile.isAdmin is true
            FlowRouter.go 'notices'
          else if user.profile.isApproved is true
            FlowRouter.go 'news'
          else if user.profile.isManager is true and user.profile.isApproved is true
            FlowRouter.go 'news'
          else
            swal "로그인 실패", "디자이너, 관리자만 로그인 가능합니다", "error"
            Meteor.logout()

  'click #facebook-login': (e, t) ->
    Meteor.loginWithFacebook {}, (error) ->
      if error
        console.log 'error ', error

        if error?.reason is "Email already exists."
          swal "로그인 실패", "이미 이메일로 가입하셨습니다. 이메일 계정으로 로그인해 주세요", "error"
      else
        $('#email').val('')
        $('#password').val('')
        user = Meteor.user()
        if user.profile.isActive is false
          swal "로그인 실패", "디자이너, 관리자만 로그인 가능합니다", "error"
        else
          if user.profile.isAdmin is true
            FlowRouter.go 'notices'
          else if user.profile.isApproved is true
            FlowRouter.go 'news'
          else if user.profile.isManager is true and user.profile.isApproved is true
            FlowRouter.go 'news'
          else
            swal "로그인 실패", "디자이너, 관리자만 로그인 가능합니다", "error"
            Meteor.logout()