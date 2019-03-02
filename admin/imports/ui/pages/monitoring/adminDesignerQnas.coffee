require './adminDesignerQnas.tpl.jade'

{ saveAs } = require '/imports/api/client/FileSaver.min.js'
{ state } = require '/imports/ui/components/searchForm.coffee'
{ buildQuery } = require '/imports/ui/components/searchForm.coffee'

Template.adminDesignerQnas.onCreated ->
  @subscribe 'qnas.admin.designer'
  @qna = new ReactiveVar ''
  @answered = new ReactiveVar true
  @nonAnswered = new ReactiveVar true

Template.adminDesignerQnas.onRendered ->
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

Template.adminDesignerQnas.events

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
      designer = Meteor.users.findOne(qna.designerId)
      answeredAt = if qna.answeredAt then qna.answeredAt else '-'

      obj = {}
      obj['등록일'] = qna.createdAt
      obj['문의자'] = user.profile.userName
      #      obj['문의자 이메일'] = user.emails[0].address
      obj['재목'] = qna.title
      obj['디자이너'] = designer.profile.designerName
      obj['상태'] = if qna.isAnswered is false then '답변 대기중' else '답변 완료'
      obj['처리일시'] = answeredAt
      rawData.push obj
    csv = json2csv rawData, true, true
    blob = new Blob [csv], {type: "text/plain;charset=utf-8;",}
    saveAs blob, "designerQna.csv"

  'click #qnaPopup-btn' : (e, t) ->
    t.qna.set Blaze.getData(e.target)
    $('#answer').val('')
    $('.qnaModal').modal 'show'

Template.adminDesignerQnas.helpers
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

  designerName : ( designerId ) ->
    user = Meteor.users.findOne(designerId)
    user?.profile.designerName

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



