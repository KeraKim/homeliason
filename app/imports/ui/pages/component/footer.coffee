require './footer.tpl.jade'

Template.footer.events
  'click #designerApplyButton' : (e, t) ->
#    if Meteor.user().profile.isDesigner
#      sweetAlert '디자이너 신청', '디자이너 신청이 완료되었습니다.', 'warning'
#    else
      FlowRouter.go 'application'

  'click .routerText': (e, t) ->
    FlowRouter.go $(e.currentTarget).attr('name')

  'click #qnaPopup-btn' : (e, t) ->
    $('.qnaPopup').toggleClass 'reveal-modal'
    $('.modal-screen').toggleClass 'reveal-modal'
