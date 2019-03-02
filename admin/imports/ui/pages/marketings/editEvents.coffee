require './editEvents.tpl.jade'

pageInit = ->
#  $('#content').froalaEditor
#    height: 300
  $('#content').summernote
    height: 300

  $(".datetimepicker").datetimepicker
    format: 'YYYY-MM-DD HH:mm'

Template.editEvents.onCreated ->
  @state = new ReactiveDict()
  @imageUrl = new ReactiveVar ''
  @eventId = FlowRouter.getParam 'id'
  @editMode = false
  @event = new ReactiveVar ''

  console.log 'ID : ', @eventId
  if @eventId
    @editMode = true
  if @editMode
    @subscribe 'event', @eventId

Template.editEvents.onRendered ->
  pageInit()

  if @eventId
    @autorun =>
      @event.set Events.findOne @eventId
      if @event.get()
        $('#startsAt').val( moment(@event.get().startsAt).format('YYYY-MM-DD HH:mm') )
        $('#endsAt').val( moment(@event.get().endsAt).format('YYYY-MM-DD HH:mm') )
#        $('#content').froalaEditor('html.set', @event.get().content )
        $('#content').summernote 'code', @event.get().content
        @imageUrl.set @event.get().imageUrl
        @state.set 'isEndless', @event.get().isEndless
  @autorun =>
    isEndless = @state.get 'isEndless'


  $('#event-form').validate
    rules:
      title :
        required : true
      url :
        required : true
        url : true

    messages:
      title :
        required : '제목을 입력해 주세요'
      url :
        required : 'URL을 입력해 주세요'
        url : 'URL 형식에 맞지 않습니다. (http:// 까지 입력해주세요)'

    submitHandler: (form, validator) ->
      eventId = Template.instance().eventId

      event =
        startsAt : $('#startsAt').val()
        endsAt : $('#endsAt').val()
        isEndless : $('#isEndless').is(':checked')
        title : $('#title').val()
        content : $('#content').val()
        linkUrl : $('#url').val()
        imageUrl : Template.instance().imageUrl.get()

      if event.content is ''
        swal "내용 없음", "내용을 입력해주세요", "error"
        return false
      else
        if eventId
          Meteor.call 'events.update', event, eventId, (error, result)->
            if error
              console.log error
            else
              FlowRouter.go 'events'
        else
          Meteor.call 'events.insert', event, (error, result)->
            if error
              console.log error
            else
              FlowRouter.go 'events'

Template.editEvents.events

  'click #submit' : (e, t) ->
    e.preventDefault()
    $('#event-form').submit()

  'click #isEndless': (e)->
    Template.instance().state.set 'isEndless', $('#isEndless').is(':checked')

  'change #inputImage': (e, t)->

    file = $("#inputImage").get(0).files[0]

    _URL = window.URL or window.webkitURL
    img = new Image

    instance = Template.instance()

    img.onload = ->

      width = 825
      height = Math.round(@height * width / @width)

      canvas = document.createElement 'canvas'
      canvas.width = width
      canvas.height = height
      ctx = canvas.getContext '2d'
      ctx.drawImage img, 0, 0, width, height

      resizeFile = dataURItoBlob(canvas.toDataURL 'image/png')

      imageUploader.send resizeFile, (err, downloadUrl) ->
        if err
          console.log "error", err
        else
          instance.imageUrl.set downloadUrl

    img.src = _URL.createObjectURL(file)

  'click #preview' : (e, t) ->
    $('.appendTitleDiv').html $('#title').val()
    $('.appendContentDiv').html $('#content').val()
    $('.previewModal').modal 'show'

Template.editEvents.helpers
  event : ->
    event = Template.instance().event.get()
    console.log '이벤트 : ', event
    event

  isEndless: ->
    Template.instance().state.get 'isEndless'

  imageUrl: ->
    Template.instance().imageUrl.get()

  selectedTargetOS: ->
    notice = Notices.findOne FlowRouter.getParam('id')
    if notice?
      notice.targetOS
  selectedTargetOS: ->
    notice = Notices.findOne FlowRouter.getParam('id')
    if notice?
      notice.targetOS