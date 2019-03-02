require './qnas.tpl.jade'

{ saveAs } = require '/imports/api/client/FileSaver.min.js'
{ state } = require '/imports/ui/components/searchForm.coffee'
{ buildQuery } = require '/imports/ui/components/searchForm.coffee'

Template.qnas.onCreated ->
  @subscribe 'qnas.admin.site'
  @qna = new ReactiveVar ''
  @answered = new ReactiveVar true
  @nonAnswered = new ReactiveVar true
  @designer = new ReactiveVar true
  @user = new ReactiveVar true

Template.qnas.onRendered ->
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

Template.qnas.events

  'change input[name=answered]': (e, t)->
    value = $('[name=answered]').is ':checked'
    t.answered.set value

  'change input[name=nonAnswered]': (e, t)->
    value = $('[name=nonAnswered]').is ':checked'
    t.nonAnswered.set value

  'change input[name=designer]': (e, t)->
    value = $('[name=designer]').is ':checked'
    t.designer.set value

  'change input[name=user]': (e, t)->
    value = $('[name=user]').is ':checked'
    t.user.set value

  'click #btnExcel': (e)->
    query = buildQuery()
    rawData = []
    Qnas.find(query).map (qna) ->

      user = Meteor.users.findOne(qna.userId)
      answeredAt = if qna.answeredAt then qna.answeredAt else '-'

      obj = {}
      obj['등록일'] = qna.createdAt
      obj['구분'] = qna.type
      obj['문의자'] = user.profile.userName
#      obj['문의자 이메일'] = user.emails[0].address
      obj['재목'] = qna.title
      obj['상태'] = if qna.isAnswered is false then '답변 대기중' else '답변 완료'
      obj['처리일시'] = answeredAt
      rawData.push obj
    csv = json2csv rawData, true, true
    blob = new Blob [csv], {type: "text/plain;charset=utf-8;",}
    saveAs blob, "qna.csv"

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
        swal '답변 완료', '답변이 작성되었습니다.', 'success'
        mailDateObject = {
          templateName : '[홈리에종] 문의사항에 대한 답변을 보내드립니다.',
          content1 : t.qna.get().title,
          content2 : $('.question-text').text(),
          content3 : $('#answer').val()
        }
        Meteor.call 'mandrill', qna.email, '홈리에종 사용자님', '[홈리에종] 1:1 문의에 답변 보내드렸습니다. 홈페이지를 확인해 주세요.', mailDateObject, (error, result) ->
          if error
            console.log error
          else
            console.log result


Template.qnas.helpers
  qnas : ->
    query = buildQuery()
    answered = Template.instance().answered.get()
    nonAnswered = Template.instance().nonAnswered.get()
    designer = Template.instance().designer.get()
    user = Template.instance().user.get()
    if answered is true and nonAnswered is false
      query.isAnswered = true
    if nonAnswered is true and answered is false
      query.isAnswered = false

    if designer is true and user is false
      query.type =
        $or:[
          type : '리뷰 이의제기'
        ,
          type : '이벤트 신청'
        ]
    if user is true and designer is false
      query.type = '사이트 문의'
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
    if user?
      user.profile.userName

  portfolioName : (portfolioId) ->
    portfolio = Portfolios.findOne(portfolioId)
    if portfolio?
      portfolio.title

  productName : (productId) ->
    product = Products.findOne(productId)
    if product?
      product.title

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



