require './editSns.tpl.jade'

Template.editSns.onCreated ->
#  @subscribe 'designer', Meteor.userId()
  @designerId = new ReactiveVar ''

Template.editSns.onRendered ->
  @autorun =>
    unless Meteor.user()
      return
    if Meteor.user().profile.isManager
      @designerId.set Meteor.user().profile.designerId
      @subscribe 'designer', @designerId.get()
    else
      @designerId.set Meteor.userId()
      @subscribe 'designer', Meteor.userId()

  instance = Template.instance()

  $('#sns-form').validate
    rules:
      homepageUrl:
        url : true
      blogUrl :
        url : true
      instagramUrl:
        url : true
      twitterUrl :
        url : true
      facebookUrl :
        url : true

    messages:
      homepageUrl:
        url : '올바른 URL 주소를 넣어주세요 (http:// 를 앞에 붙혀주세요)'
      blogUrl :
        url : '올바른 URL 주소를 넣어주세요 (http:// 를 앞에 붙혀주세요)'
      instagramUrl:
        url : '올바른 URL 주소를 넣어주세요 (http:// 를 앞에 붙혀주세요)'
      twitterUrl :
        url : '올바른 URL 주소를 넣어주세요 (http:// 를 앞에 붙혀주세요)'
      facebookUrl :
        url : '올바른 URL 주소를 넣어주세요 (http:// 를 앞에 붙혀주세요)'

    submitHandler: (form, validator) ->
      sns =
        homepageUrl : $('#homepageUrl').val()
        blogUrl : $('#blogUrl').val()
        instagramUrl : $('#instagramUrl').val()
        twitterUrl : $('#twitterUrl').val()
        facebookUrl : $('#facebookUrl').val()

      Meteor.call 'designer.editSns', sns, instance.designerId.get(), (error, result)->
        if error
          console.log error
        else
          swal "성공", "SNS 정보가 변경되었습니다.", "success"

Template.editSns.events
  'click #submit-button' : (e, t) ->
    $('#sns-form').submit()

Template.editSns.helpers
  designer : ->
    Meteor.users.findOne Template.instance().designerId.get()
