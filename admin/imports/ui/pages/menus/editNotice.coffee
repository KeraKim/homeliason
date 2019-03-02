require './editNotice.tpl.jade'

pageInit = ->
  $('#details').summernote
    height: 300
#  $('#details').froalaEditor
#    height: 300

  $(".datetimepicker").datetimepicker
#    locale: 'ko'
    format: 'YYYY-MM-DD HH:mm'


#  $('.clockpicker').clockpicker()

Template.editNotice.onCreated ->
  @state = new ReactiveDict()
  @noticeId = FlowRouter.getParam 'id'
  @editMode = false

  if @noticeId
    @editMode = true
  if @editMode
    @subscribe 'notice', @noticeId
#  else
#    @newNotice = new Notice()

Template.editNotice.onRendered ->
  pageInit()

  if @editMode
    @autorun =>
      @notice = Notices.findOne @noticeId
      if @notice?
        console.log 'autorun notice: ', @notice
        $('#startsAt').val( moment(@notice.startsAt).format('YYYY-MM-DD HH:mm') )
        $('#endsAt').val( moment(@notice.endsAt).format('YYYY-MM-DD HH:mm') )
        $('#title').val( @notice.title )
#        $('#details').froalaEditor('html.set', @notice.content )
        $('#details').summernote 'code', @notice.content
        @state.set 'isEndless', @notice.isEndless
  @autorun =>
    isEndless = @state.get 'isEndless'
#      unless isEndless


Template.editNotice.events
  'submit form': (e)->
    e.preventDefault()

    instance = Template.instance()
    notice = instance.notice
    unless notice
      notice = {}

    notice.startsAt = moment($('#startsAt').val()).toDate()        # 기간설정
    notice.endsAt = moment($('#endsAt').val()).toDate()
    notice.isEndless = $('#isEndless').is(':checked')
    notice.title= $('#title').val()                   # 제목
    notice.content= $('#details').val()              # 상세요강

    console.log 'notice before save', notice
    if instance.editMode
      Meteor.call 'notices.update', notice._id, notice, (error, result)->
        if error
          console.log error
        else
          FlowRouter.go 'notices'
    else
      Meteor.call 'notices.add', notice, (error, result)->
        if error
          console.log error
        else
          FlowRouter.go 'notices'

  'click #isEndless': (e)->
    Template.instance().state.set 'isEndless', $('#isEndless').is(':checked')

Template.editNotice.helpers
  state: (key)->
    Template.instance().state.get key

#  notice: ->
#    Notices.findOne FlowRouter.getParam('id')
#    if Template.instance().editMode

#    else
#      Template.instance().newNotice


  isEndless: ->
    Template.instance().state.get 'isEndless'

  selectedTargetOS: ->
    notice = Notices.findOne FlowRouter.getParam('id')
    if notice?
      notice.targetOS
  selectedTargetOS: ->
    notice = Notices.findOne FlowRouter.getParam('id')
    if notice?
      notice.targetOS