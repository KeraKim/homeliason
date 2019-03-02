require './mainMenuLayout.tpl.jade'

Template.mainMenuLayout.onRendered ->
#  @autorun =>
#    console.log 'connection: ', Meteor.status().status
#    if Meteor.status().status is 'waiting'
#      console.log 'connection waiting................'
#      console.log Meteor.status()
#    if Meteor.status().retryCount > 3
#      alert '서버와의 연결이 끊어졌습니다. 나중에 다시 시도해 주세요.'
#      Meteor.disconnect()
  $(window).scroll ->
    height = $(document).scrollTop()
    if height > 500
      $('.mobile-top-button').css('visibility', 'visible')
    else if height < 500
      $('.mobile-top-button').css('visibility', 'hidden')


Template.mainMenuLayout.events

  'click .modal-screen, click .popupClose-button' : (e, t) ->
    $('.foundry_modal').removeClass 'reveal-modal'
    $('.modal-screen').removeClass 'reveal-modal'

  'click .mobile-toggle' : (e, t) ->
    $('.nav-bar').toggleClass 'nav-open'
    $(this).toggleClass 'active'

  'click .mobile-top-button' : (e, t) ->
    document.body.scrollTop = 0



