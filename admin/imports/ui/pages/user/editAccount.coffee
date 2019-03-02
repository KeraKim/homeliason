require './editAccount.tpl.jade'

Template.editAccount.onCreated ->
  @subscribe 'designer', Meteor.userId()
  @designerId = new ReactiveVar ''

Template.editAccount.onRendered ->

  @autorun =>
    unless Meteor.user()
      return
    if Meteor.user().profile.isManager
      @designerId.set Meteor.user().profile.designerId
      @subscribe 'designer', @designerId.get()
    else
      @designerId.set Meteor.userId()
      @subscribe 'designer', @designerId.get()

  instance = Template.instance()

  $('#account-form').validate
    rules:
      bankName:
        required: true
      accountName :
        required: true
      accountNumber:
        required : true
        number: true

    messages:
      bankName:
        required : '필수 입력 사항입니다.'
      accountName :
        required : '필수 입력 사항입니다.'
      accountNumber:
        required : '필수 입력 사항입니다.'
        number: '숫자로만 입력해 주세요'

    submitHandler: (form, validator) ->
      account =
        bankName : $('#bankName').val()
        accountName : $('#accountName').val()
        accountNumber : $('#accountNumber').val()

      Meteor.call 'designer.account.edit', account, instance.designerId.get(), (error, result)->
        if error
          console.log error
        else
          swal "성공", "계좌 정보가 변경되었습니다.", "success"


Template.editAccount.events
  'click #submit-button': (e, t) ->
    $('#account-form').submit()

Template.editAccount.helpers
  designer : ->
    Meteor.users.findOne Template.instance().designerId.get()
