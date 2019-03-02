require './editDesignerProfile.tpl.jade'

squareCrop = null
rectangleCrop = null
rectangleImageUrl = ''
squareImageUrl = ''

pageInit = ->
#  $('#detailInfo').froalaEditor
#    height: 300
  $('#detailInfo').summernote
    height: 300
    placeholder: '디자이너 상세 페이지에 보이는 자세한 소개글입니다. 평소 좋아하시는 디자이너, 스타일, 일상, 향후 비전 등에 대해서 자유롭게 설명하시면서 매력적으로 보이도록 어필하는 공간입니다.'

designersEditProfile = (designerId) ->

  profile =
    designerName : $('#name').val()
    simpleInfo : $('#simpleInfo').val()
    detailInfo : $('#detailInfo').val()
    activeArea : $('#activeArea').val()
    specialty : $('#specialty').val()
    designerRectangleImageUrl : rectangleImageUrl
    designerSquareImageUrl : squareImageUrl
    isWriteProfile : true

  swal
    title: "정보 변경"
    text: "디자이너 정보를 변경하시겠습니까?"
    type: "warning"
    showCancelButton: true
    cancelButtonText: '취소'
    confirmButtonText: "변경"
    closeOnConfirm: false
    html: false
  , ->

    if profile.designerRectangleImageUrl is '' or profile.designerSquareImageUrl is ''
      swal "디자이너 정보", "프로필 사진을 등록해주세요.", "error"
      return

    Meteor.call 'designers.editProfile', profile, designerId, (error, result)->
      if error
        console.log error
      else
        swal "디자이너 정보", "저장이 완료되었습니다.", "success"


Template.editDesignerProfile.onCreated ->
  @state = new ReactiveDict()
  @state.set 'squareImageUrl', ''
  @state.set 'rectangleImageUrl', ''
  @state.set 'designer', ''
  @state.set 'newImageUpload', false
  @designerId = new ReactiveVar ''

Template.editDesignerProfile.onRendered ->

  pageInit()

  @autorun =>
    unless Meteor.user()
      return
    if Meteor.user().profile.isManager
      @designerId.set Meteor.user().profile.designerId
      @subscribe 'designer', @designerId.get()
    else
      @designerId.set Meteor.userId()

    designer = Meteor.users.findOne(@designerId.get())
    console.log designer
    if designer?
      @state.set 'designer', designer
      @state.set 'squareImageUrl', designer.profile.designerSquareImageUrl
      squareImageUrl = designer.profile.designerSquareImageUrl
      @state.set 'rectangleImageUrl', designer.profile.designerRectangleImageUrl
      rectangleImageUrl = designer.profile.designerRectangleImageUrl
#      $('#detailInfo').froalaEditor('html.set', designer.profile.detailInfo )
      $('#detailInfo').summernote 'code', designer.profile.detailInfo

  image = document.getElementById('image')
  squareCrop = new Croppie(image,
    viewport:
      width: 300
      height: 300
    boundary:
      width: 400
      height: 400
    showZoomer: false
    enableOrientation: false
  )

  image2 = document.getElementById('image2')
  rectangleCrop = new Croppie(image2,
    viewport:
      width: 300
      height: 150
    boundary:
      width: 400
      height: 400
    showZoomer: false
    enableOrientation: false
  )

  instance = Template.instance()

  $('#designer-form').validate
    rules:
      name:
        required: true
      simpleInfo :
        required: true
      detailInfo :
        required: true
      activeArea :
        required : true
      specialty :
        required : true

    messages:
      name:
        required: '활동명은 필수 입력사항 입니다.'
      simpleInfo :
        required: '간단 설명은 필수 입력사항 입니다.'
      detailInfo :
        required: '자세한 설명은 필수 입력사항 입니다.'
      activeArea :
        required : '활동지역은 필수 입력사항 입니다.'
      specialty :
        required : '전문분야는 필수 입력사항 입니다.'

    submitHandler: (form, validator) ->

      uploader = new Slingshot.Upload("imageUpload")

      if instance.state.get('newImageUpload')
        squareCrop.result('blob').then (blob) ->

          uploader.send blob, (err, downloadUrl) ->
            if err
              console.log "error : ", err
            else
              instance.state.set 'squareImageUrl', downloadUrl
              squareImageUrl = downloadUrl
              if downloadUrl?
                rectangleCrop.result('blob').then (blob) ->
                  uploader.send blob, (err, downloadUrl) ->
                    if err
                      console.log "error : ", err
                    else
                      instance.state.set 'rectangleImageUrl', downloadUrl
                      rectangleImageUrl = downloadUrl
                      if downloadUrl?
                        designersEditProfile(instance.designerId.get())
      else
        designersEditProfile(instance.designerId.get())

#      profile =
#        designerName : $('#name').val()
#        simpleInfo : $('#simpleInfo').val()
#        detailInfo : $('#detailInfo').val()
##        detailInfo : $('#detailInfo').froalaEditor('html.get')
#        activeArea : $('#activeArea').val()
#        specialty : $('#specialty').val()
#        designerRectangleImageUrl : instance.state.get('rectangleImageUrl')
#        designerSquareImageUrl : instance.state.get('squareImageUrl')
#        isWriteProfile : true
#
#      if profile.designerRectangleImageUrl is '' or profile.designerSquareImageUrl is ''
#        swal "디자이너 정보", "프로필 사진을 등록해주세요.", "error"
#        return
#
#      Meteor.call 'designers.editProfile', profile, instance.designerId.get(), (error, result)->
#        if error
#          console.log error
#        else
#          swal "디자이너 정보", "저장이 완료되었습니다.", "success"

Template.editDesignerProfile.events

  'click #deleteImage': (e, t) ->
    Template.instance().imageUrl.set []

  'click #submit-button': (e, t) ->
    $('#designer-form').submit()

  'submit #designer-form': (e, t) ->
    e.preventDefault();
#
#    if t.state.get('newImageUpload')
#      squareCrop.result('blob').then (blob) ->
#        imageUploader.send blob, (err, downloadUrl) ->
#          if err
#            console.log "error", err
#          else
#            t.state.set 'squareImageUrl', downloadUrl
#            if downloadUrl?
#              rectangleCrop.result('blob').then (blob) ->
#                imageUploader.send blob, (err, downloadUrl) ->
#                  if err
#                    console.log "error", err
#                  else
#                    t.state.set 'rectangleImageUrl', downloadUrl
#
#    swal
#      title: "정보 변경"
#      text: "디자이너 정보를 변경하시겠습니까?"
#      type: "warning"
#      showCancelButton: true
#      cancelButtonText: '취소'
#      confirmButtonText: "변경"
#      closeOnConfirm: false
#      html: false
#    , ->
#      console.log t.state.get('squareImageUrl')
#      console.log t.state.get('rectangleImageUrl')
#      $('#designer-form').submit()

  'change #inputImage': (e, t) ->
    _URL = window.URL or window.webkitURL

    file = $(e.target).get(0).files[0]
    img = new Image

    img.onload = ->
      if @width < 300 or @height < 300
        swal '부적합한 사이즈', '프로필 사진은 가로300px, 세로 300px 이상 되는 사진부터 등록가능합니다', 'warning'
        return
      else if @width >= 300 and @height >= 300

        t.state.set 'newImageUpload', true
        $('.image-div').show()
        $('.deforeImage-div').hide()

        imageUploader.send file, (err, downloadUrl) ->
          if err
            console.log "error", err
          else
            squareCrop.bind
              url: downloadUrl
            rectangleCrop.bind
              url: downloadUrl
    img.src = _URL.createObjectURL(file)

Template.editDesignerProfile.helpers
  designerInfo : () ->
    designer = Template.instance().state.get 'designer'
    unless  designer
      return
    designer



