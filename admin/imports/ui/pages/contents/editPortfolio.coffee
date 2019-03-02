require './editPortfolio.tpl.jade'

pageInit = ->
#  $('#details').froalaEditor
#    height: 300
  $('#details').summernote
    height: 300
    placeholder: '포트폴리오 상세 페이지에 보이는 자세한 소개글입니다. 해당 포트폴리오의 디자인 컨셉, 디자인 과정, 특별한 에피소드 등 관련된 내용을 자유롭게 설명할 수 있습니다.'
    callbacks:
      onImageUpload: (files) =>
        imageUploader.send files[0], (err, downloadUrl) ->
          if err
            console.log "error", err
          else
            $('#details').summernote 'insertImage', downloadUrl

  $("#tag").tagit()

{ sojaeji } = require '/imports/api/client/sojaeji.coffee'

dataURItoBlob = (dataURI) ->

  byteString = atob(dataURI.split(',')[1])

  mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0]

  ab = new ArrayBuffer(byteString.length)
  ia = new Uint8Array(ab)
  i = 0
  while i < byteString.length
    ia[i] = byteString.charCodeAt(i)
    i++
  new Blob([ ab ], type: mimeString)

Template.editPortfolio.onCreated ->
  @imageUrl = new ReactiveVar []
  @portfolio = new ReactiveVar ''
  @month = new ReactiveVar ''
  @portfolioId = FlowRouter.getParam 'id'
  @editMode = false
  @designerId = new ReactiveVar ''
  @tagSearch = new ReactiveVar ''

  @subscribe 'tags'
  if @portfolioId
    @editMode = true
    @subscribe 'portfolio', @portfolioId

Template.editPortfolio.onRendered ->
  pageInit()

#  @autorun =>
#    if @subscriptionsReady()
#      Tracker.afterFlush =>
#
#        tags = Tags.find()
#        tagNames = []
#        tags.forEach ( tag ) ->
#          tagNames.push tag.tagName
#
#          $('#tag').tagit availableTags: tagNames


  if @subscriptionsReady()
    Tracker.afterFlush =>

      tags = Tags.find()
      tagNames = []
      tags.forEach ( tag ) ->
        tagNames.push tag.tagName

        $('#tag').tagit availableTags: tagNames

  unless @editMode
    sojaeji '서울', '강남구'



#  unless Meteor.user()
#    return
#  if Meteor.user().profile.isManager
#    @designerId.set Meteor.user().profile.designerId
#  else
#    @designerId.set Meteor.userId()

  @autorun =>
    unless Meteor.user()
      return
    if Meteor.user().profile.isManager
      @designerId.set Meteor.user().profile.designerId
    else
      @designerId.set Meteor.userId()

  if @editMode
    @autorun =>
      @portfolio.set Portfolios.findOne @portfolioId
      @imageUrl.set @portfolio.get()?.imageUrl
      sojaeji @portfolio.get()?.sido, @portfolio.get()?.gugun
      $('#year').val(@portfolio.get()?.workedYear)
      $('#month').val(@portfolio.get()?.workedMonth)
#      $('#day').val(@portfolio.get()?.workedDay)
#      $('#details').froalaEditor('html.set', @portfolio.get()?.detailInfo )
      $('#details').summernote 'code', @portfolio.get()?.detailInfo
      if @portfolio.get()?.tags?
        for tag in @portfolio.get().tags
          $("#tag").tagit("createTag", tag)

  $.validator.addMethod 'valueNotEquals', ((value, element, arg) ->
    arg != value
  ), '작업 년도는 필수 선택사항 입니다.'

  instance = Template.instance()

  $('#portfolio-form').validate
    rules:
      title:
        required: true
      year:
        valueNotEquals: '0'
      simpleInfo :
        required: true
      detailInfo :
        required: true
      tag :
        required : true

    messages:
      title:
        required: '제목은 필수 입력사항 입니다.'
      simpleInfo :
        required: '간단 설명은 필수 입력사항 입니다.'
      detailInfo :
        required: '내용은 필수 입력사항 입니다.'
      tag :
        required : '태그는 필수 입력사항 입니다.'

    submitHandler: (form, validator) ->
      tags = $('#tag').val().split(',')
      trimTags = []
      i = 0
      while i < tags.length
        trimTags.push tags[i].trim()
        i++

      content =
        title : $('#title').val()
        sido : $('#sido').val()
        gugun : $('#gugun').val()
        workedYear : $('#year').val()
        workedMonth : $('#month').val()
#        workedDay : $('#day').val()
        simpleInfo : $('#simple').val()
        detailInfo : $('#details').val()
#        detailInfo : $('#details').froalaEditor('html.get')
#        tags : trimTags
        tags : $("#tag").tagit("assignedTags")
        progressedByHomeLiaison : $('#progressedByHomeLiaison').is(':checked')
        imageUrl : instance.imageUrl.get()

      if content.imageUrl.length is 0
        swal "이미지 미선택", "하나 이상의 이미지를 업로드 해주세요", "error"
      else
        if instance.editMode
          Meteor.call 'portfolios.edit',instance.portfolioId, content, (error, result)->
            if error
              console.log error
            else
              FlowRouter.go 'portfolios'
        else
          Meteor.call 'portfolios.add', content, instance.designerId.get(), (error, result)->
            if error
              console.log error
            else
              FlowRouter.go 'portfolios'

Template.editPortfolio.events

  'keyup .tagit': (e, t) ->
    console.log $(e.currentTarget).text()

  'change .selectMonth' : (e, t) ->
    Template.instance().month.set $('.selectMonth').val()

  'change #inputImage': (e, t)->

    for file in $("#inputImage").get(0).files

        uploader = new Slingshot.Upload("imageUpload")
        uploader.send file, (err, downloadUrl) ->
          if err
            console.log "error : ", err
          else
            console.log 'downloadUrl : ', downloadUrl

            image = new Image
            image.src = downloadUrl

            image.onload = ->
              if @width < 825
                swal '부적합한 사이즈', '권장사이즈는 가로 825px 이상되는 사진입니다', 'warning'
              else
                array = t.imageUrl.get()
                array.push downloadUrl
                t.imageUrl.set array



#            console.log $('<img class="test1" src="'+downloadUrl+'"></img>').naturalWidth
#            console.log $('<img class="test1" src="'+downloadUrl+'"></img>')[0].width
#            console.log $('<img class="test1" src="'+downloadUrl+'"></img>')[0].naturalWidth
#            console.log $('<img class="test1" src="'+downloadUrl+'"></img>').get(0).naturalWidth
#            console.log $(image).naturalWidth





#    for file in $("#inputImage").get(0).files
#
#      console.log 'file : ', file
#
#      Resizer.resize file, {
#        width: 825
#        height: 825
#        cropSquare: false
#      }, (error, file) ->
#        console.log 'file : ', file
#        uploader = new Slingshot.Upload("imageUpload")
#        uploader.send file, (err, downloadUrl) ->
#          if err
#            console.log "error : ", err
#          else
#            console.log 'downloadUrl : ', downloadUrl
#
#            img = new Image
#
#            img.onload = ->
#
#              console.log '@width : ', @width
#              if @width < 500
#                swal '부적합한 사이즈', '권장사이즈는 4:3 비율에 가로 825px 이상되는 사진입니다', 'warning'
#                return
#              else if @width >= 500
#                array = t.imageUrl.get()
#                array.push downloadUrl
#                t.imageUrl.set array
#
#            img.src = downloadUrl




#    file = $("#inputImage").get(0).files[0]
#
#    _URL = window.URL or window.webkitURL
#    img = new Image
#
#    instance = Template.instance()
#
#    img.onload = ->
#
#      width = 825
#      height = Math.round(@height * width / @width)
#
#      canvas = document.createElement 'canvas'
#      canvas.width = width
#      canvas.height = height
#      ctx = canvas.getContext '2d'
#      ctx.drawImage img, 0, 0, width, height
#
#      resizeFile = dataURItoBlob(canvas.toDataURL 'image/png')
#
#      imageUploader.send resizeFile, (err, downloadUrl) ->
#        if err
#          console.log "error", err
#        else
#          array = instance.imageUrl.get()
#          array.push downloadUrl
#          instance.imageUrl.set array
#
#    img.src = _URL.createObjectURL(file)

  'click #deleteImage': (e, t) ->
    Template.instance().imageUrl.set []

  'click #submit-button': (e, t) ->
#    $('#tag').val()
    console.log $("#tag").tagit("assignedTags")
    $(e.currentTarget).parents('form').submit()

  'click #deleteOneImage': (e, t) ->
    index = $(e.currentTarget).attr('index')
    imageUrlArray = t.imageUrl.get()
    imageUrlArray.splice(index, 1)
    t.imageUrl.set imageUrlArray


Template.editPortfolio.helpers
  imageUrl: ->
    Template.instance().imageUrl.get()

  info: (text) ->
    Template.instance().portfolio.get()?[text]

  date: (text) ->
    if text is 'year'
      currentYear = new Date().getFullYear()
      [currentYear..currentYear-100]
    else if text is 'month'
      [1..12]

  date2: ->
    month = Template.instance().month.get()
    switch month
      when '' then [1..31]
      when '2' then [1..28]
      when '1', '3', '5', '7', '8', '10', '12' then [1..31]
      else [1..30]

  progressedByHomeLiaison : ->
    Template.instance().portfolio.get()?['progressedByHomeLiaison']


