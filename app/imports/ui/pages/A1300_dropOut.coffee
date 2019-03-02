require './A1300_dropOut.tpl.jade'

Template.A1300_dropOut.onCreated ->
  @subscribe 'terms'

Template.A1300_dropOut.events
  'click #dropOutButton' : (e, t) ->
    sweetAlert
      title: "탈퇴"
      text: "정말로 탈퇴 하시겠습니까?"
      type: "warning"
      showCancelButton: true
      cancelButtonText: '취소'
#      confirmButtonColor: "#DD6B55"
      confirmButtonText: "탈퇴"
      closeOnConfirm: false
      html: false
    , ->
        Meteor.call 'user.dropout', Accounts.userId(),  (error, result)->
          if error
            console.log error
          else
            console.log result
            Meteor.logout()
        sweetAlert "결과", "회원탈퇴가 되셨습니다..", "success"
        FlowRouter.go 'index'

Template.A1300_dropOut.helpers
  terms: ->
    terms = Terms.findOne
      type : '탈퇴시 유의사항'
    unless terms
      return
    terms.text