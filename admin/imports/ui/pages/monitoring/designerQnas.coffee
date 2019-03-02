require './designerQnas.tpl.jade'

{ saveAs } = require '/imports/api/client/FileSaver.min.js'
{ state } = require '/imports/ui/components/searchForm.coffee'
{ buildQuery } = require '/imports/ui/components/searchForm.coffee'

Template.designerQnas.onCreated ->
  @designerId = new ReactiveVar ''
#  @subscribe 'qnas.designer' , Meteor.userId()
  @qna = new ReactiveVar ''
  @answered = new ReactiveVar true
  @nonAnswered = new ReactiveVar true
  @designer = undefined

Template.designerQnas.onRendered ->

  @autorun =>
    unless Meteor.user()
      return
    if Meteor.user().profile.isManager
      @designerId.set Meteor.user().profile.designerId
      @subscribe 'qnas.designer', @designerId.get()
      @subscribe 'designer', @designerId.get()
      @designer = Meteor.users.findOne @designerId.get()
    else
      @designerId.set Meteor.userId()
      @subscribe 'qnas.designer', @designerId.get()
      @subscribe 'designer', @designerId.get()
      @designer = Meteor.users.findOne @designerId.get()

  searchIdTexts = []
  initial =
    id: 'title'
    text: '제목'
  searchIdTexts.push initial
  searchIdTexts.push
    id: 'email'
    text: '문의자 이메일'
  state.set 'searchIdTexts', searchIdTexts
  state.set 'currentSearchIdText', initial
  state.set 'startsAt', ''

Template.designerQnas.events

  'change input[name=answered]': (e, t)->
    value = $('[name=answered]').is ':checked'
    t.answered.set value

  'change input[name=nonAnswered]': (e, t)->
    value = $('[name=nonAnswered]').is ':checked'
    t.nonAnswered.set value

  'click #btnExcel': (e)->
    query = buildQuery()
    rawData = []
    Qnas.find(query).map (qna) ->

      user = Meteor.users.findOne(qna.userId)
      answeredAt = if qna.answeredAt then qna.answeredAt else '-'

      obj = {}
      obj['등록일'] = qna.createdAt
      obj['문의자'] = user.profile.userName
      #      obj['문의자 이메일'] = user.emails[0].address
      obj['재목'] = qna.title
      obj['상태'] = if qna.isAnswered is false then '답변 대기중' else '답변 완료'
      obj['처리일시'] = answeredAt
      rawData.push obj
    csv = json2csv rawData, true, true
    blob = new Blob [csv], {type: "text/plain;charset=utf-8;",}
    saveAs blob, "notices.csv"

  'click #qnaPopup-btn' : (e, t) ->
    t.qna.set Blaze.getData(e.target)
    $('#answer').val('')
    $('.qnaModal').modal 'show'

  'click #answerSend-btn' : (e, t) ->
    qna = t.qna.get()
    _.extend qna,
      answer : $('#answer').val()

    Meteor.call 'qnas.answer',qna._id, qna, (error, result) ->
      if error
        console.log 'error ', error
      else
        $('.close-btn').trigger('click')
        designerName = t.designer.profile.designerName
        swal '답변 완료', '답변이 작성되었습니다.', 'success'
        mailDateObject = {
          templateName : '[홈리에종] 문의사항에 대한 답변을 보내드립니다.',
          content1 : designerName,
          content2 : t.qna.get().title,
          content3 : $('.question-text').text(),
          content4 : $('#answer').val()
        }
        Meteor.call 'mandrill', qna.email, '홈리에종 사용자님', '[홈리에종] '+designerName+'  디자이너가 문의에 답변을 보냈습니다. 홈페이지를 확인해 주세요.', mailDateObject, (error, result) ->
        if error
          console.log error
        else
          console.log result

Template.designerQnas.helpers
  qnas : ->
    query = buildQuery()
    answered = Template.instance().answered.get()
    nonAnswered = Template.instance().nonAnswered.get()
    if answered is true and nonAnswered is false
      query.isAnswered = true
    if nonAnswered is true and answered is false
      query.isAnswered = false
    #    query = {}
    page = FlowRouter.getQueryParam 'page' or 1
    limit = 10
    options =
      limit: limit
      skip: (page - 1) * limit
      sort:
        createdAt: -1
    Qnas.find query, options
#    Notices.find {}, options

  dateFormat : (date) ->
    if date
      moment(date).format('YYYY-MM-DD HH:mm')
    else
      '-'

  isAnswered : ( isAnswered ) ->
    if isAnswered
      '답변 완료'
    else
      '답변 대기 중'

  userName : ( userId ) ->
    user = Meteor.users.findOne(userId)
    user?.profile.userName

  qna : ->
    Template.instance().qna.get()

  'pageTotalCount': ->
    query = buildQuery()
    #    query = {}
    Notices.find(query).count()

  'totalCount': ->
    Notices.find().count()
#    Counts.get 'notices.total.counts'
  'totalVisibleCount': ->
    Notices.find(isVisible: true).count()
#    Counts.get 'notices.total.visible.counts'



