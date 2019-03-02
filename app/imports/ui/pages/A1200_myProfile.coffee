require './A1200_myProfile.tpl.jade'

require '../../api/client/croppie.js'

crop = null

Template.A1200_myProfile.onCreated ->

  @subscribe 'user', Meteor.userId()
  @imageUrl = new ReactiveVar ''
  @modalState = new ReactiveVar ''

Template.A1200_myProfile.onRendered ->

  @autorun =>
    @subscribe 'user', Meteor.userId()
    user = Meteor.users.findOne(Meteor.userId())
    if user?.profile?.userProfileImageUrl?
      @imageUrl.set user.profile.userProfileImageUrl
    if user?.services?.facebook?.email?
      $('#email').val(user.services.facebook.email)
      $('.facebook-logo').show()

  if document.body.clientWidth <= 786
    image = document.getElementById('profileImageCrop')
    crop = new Croppie(image,
      viewport:
        width: 200
        height: 200
        type : 'circle'
      boundary:
        width: 300
        height: 300
      showZoomer: false
      enableOrientation: false
    )
  else
    image = document.getElementById('profileImageCrop')
    crop = new Croppie(image,
      viewport:
        width: 300
        height: 300
        type : 'circle'
      boundary:
        width: 400
        height: 400
      showZoomer: false
      enableOrientation: false
    )
  $('#profile-form').validate
    rules:
      name:
        required: true

    messages:
      name:
        required: '이름을 필수로입력해주세요.'

    errorPlacement: (error, element) ->
      $(element).closest('div').find('.error-text').html error

    submitHandler: (form, validator) ->
      userProfile =
        userName : $('#userName').val()
        userProfileImageUrl : Template.instance().imageUrl.get()

      Meteor.call 'user.profileUpdate', userProfile, (error, result)->
        if error
          console.log error
        else
          sweetAlert "프로필 정보", "프로필 정보가 수정되었습니다.", "success"

Template.A1200_myProfile.events
  'click #profileImage-btn' : (e, t) ->
    $('#profileImage-input').val ''
    $('#profileImage-input').trigger('click')

  'click .profile-modal-screen, click #profileImage-cancel' : (e, t) ->
    t.modalState.set ''

  'change #profileImage-input' : (e, t) ->
    t.modalState.set 'reveal-modal'

    file = $('#profileImage-input').get(0).files[0]
    imageUploader.send file, (err, downloadUrl) ->
      if err
        console.log "error", err
      else
        crop.bind
          url: downloadUrl

    $(document).on 'wheel mousewheel scroll', '.corpPopup, .modal-screen', (evt) ->
      $(this).get(0).scrollTop += evt.originalEvent.deltaY
      false

  'click #profileImage-submit' : (e, t) ->
    crop.result('blob').then (blob) ->
      imageUploader.send blob, (err, downloadUrl) ->
        if err
          console.log "error", err
        else
          t.imageUrl.set downloadUrl
          t.modalState.set ''

  'click #profileUpdate-btn' : (e, t) ->
    $('#profile-form').submit()

  'click #resetPassword-btn' : (e, t) ->
    FlowRouter.go 'changePassword'

  'click .dropOut-btn' : (e, t) ->
    FlowRouter.go 'dropOut'

  'click #profileImageDelete-btn': (e, t) ->
    t.imageUrl.set ''






  'click .mailChimpTestButton': (e, t) ->

    Meteor.call 'mandrill', (error, result) ->
      if error
        console.log error
      else
        console.log result

  'click .alrigoTestButton': (e, t) ->
    Meteor.call 'aligo', '완료', (error, result)->
      if error
        console.log error
      else
        console.log result

  'click .forgetPassword': (e, t) ->
    Accounts.forgotPassword
      email : 'kmj0716@smartlink.io' , (error)->
    , (err) ->
      if err
        if err.message is "User not found [403]"
          console.log "This email does not exist."
      else
        console.log "Email Sent. Check your mailbox."

  'click .resetPassword': (e, t) ->
    Accounts.resetPassword $('.testinputToken').val(), $('.testinputNewpasword').val() , (error, result) ->
      if error
        console.log 'error ' ,error
      else
        console.log 'success ' , result

#  'click #dropout' : (e, t) ->
#    Meteor.call 'user.dropout', (error, result)->
#      if error
#        console.log error
#      else
#        console.log 'success'

Template.A1200_myProfile.helpers

  imageUrl : ->
    imageUrl = Template.instance().imageUrl.get()
    if imageUrl is ''
      '/img/default-user.png'
    else
      imageUrl

  modalState : ->
    state = Template.instance().modalState.get()
    if state is ''
      ''
    else
      'reveal-modal'