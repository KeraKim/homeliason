require './A1100_qnas.tpl.jade'

Template.A1100_qnas.onCreated ->

  @subscribe 'qnas.user', Meteor.userId()
  @qnaId = new ReactiveVar ''

Template.A1100_qnas.onRendered ->

  $('.rateYo').rateYo
    rating: 1.5
    halfStar: true
    ratedFill: "#ffed00"
    normalFill: "#FEF9C9"
    starWidth: "30px"

Template.A1100_qnas.events

  'click td' : (e, t) ->
    qnaId = Blaze.getData(e.target)._id
    t.qnaId.set qnaId
    modal = $('.userViewQnaPopup')
    modal.toggleClass 'reveal-modal'
    $('.modal-screen').toggleClass 'reveal-modal'

  $(document).on 'wheel mousewheel scroll', '.foundry_modal, .modal-screen', (evt) ->
    $(this).get(0).scrollTop += evt.originalEvent.deltaY
    false

Template.A1100_qnas.helpers

  qnas : ->
    Qnas.find( userId : Meteor.userId() )

  qna : ->
    qnaId = Template.instance().qnaId.get()
    Qnas.findOne qnaId

  dateFormat : (date) ->
    moment(date).format('YYYY-MM-DD')

  portfolio : (portfolioId) ->
    portfolio = Portfolios.findOne(portfolioId)
    unless portfolio
      return
    portfolio.title

  designer : (designerId) ->
    designer = Meteor.users.findOne(designerId)
    unless  designer
      return
    designer.profile.designerName