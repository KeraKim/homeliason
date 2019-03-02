require './editFaq.tpl.jade'

pageInit = ->
  $('#details').summernote
    height: 300
#  $('#details').froalaEditor
#    height: 300

  $(".datetimepicker").datetimepicker
#    locale: 'ko'
    format: 'YYYY-MM-DD HH:mm'


#  $('.clockpicker').clockpicker()

Template.editFaq.onCreated ->
  @state = new ReactiveDict()
  @faqId = FlowRouter.getParam 'id'
  @editMode = false

  if @faqId
    @editMode = true
  if @editMode
    @subscribe 'faq', @faqId
#  else
#    @newNotice = new Notice()

Template.editFaq.onRendered ->
  pageInit()

  if @editMode
    @autorun =>
      @faq = Faqs.findOne @faqId
      if @faq?
        $('#title').val( @faq.title )
#        $('#details').froalaEditor('html.set', @faq.content )
        $('#details').summernote 'code', @faq.content

Template.editFaq.events
  'submit form': (e)->
    e.preventDefault()

    instance = Template.instance()
    faq = instance.faq
    unless faq
      faq = {}

    #    notice.targetOS = $('#targetOS').val()                     # 주최
    #    notice.noticeType = $('#noticeType').val()           # 주관
    faq.title= $('#title').val()                   # 제목
    faq.content= $('#details').val()              # 상세요강

    console.log 'faq before save', faq
    if instance.editMode
      Meteor.call 'faqs.update', faq._id, faq, (error, result)->
        if error
          console.log error
        else
          FlowRouter.go 'faqs'
    else
      Meteor.call 'faqs.add', faq, (error, result)->
        if error
          console.log error
        else
          FlowRouter.go 'faqs'

Template.editFaq.helpers
  state: (key)->
    Template.instance().state.get key