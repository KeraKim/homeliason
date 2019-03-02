require './complainReview.tpl.jade'

Template.complainReview.onCreated ->
  @designerId = new ReactiveVar ''
#  @subscribe 'designer.products', Meteor.userId()
  @portfolioId = new ReactiveVar ''

Template.complainReview.onRendered ->
  @autorun =>
    unless Meteor.user()
      return
    if Meteor.user().profile.isManager
      @designerId.set Meteor.user().profile.designerId
      @subscribe 'designer.products', @designerId.get()
    else
      @designerId.set Meteor.userId()
      @subscribe 'designer.products', @designerId.get()

  $.validator.addMethod 'valueNotEquals', ((value, element, arg) ->
    arg != value
  ), '항목을 선택해 주세요.'

  instance = Template.instance()

  $('#complaninReview-form').validate
    rules:
      title :
        required : true
      writer:
        required : true
      content :
        required : true
      portfolio :
        valueNotEquals : '-1'
      product :
        valueNotEquals : '-1'

    messages:
      title :
        required : '제목을 입력해 주세요'
      writer:
        required : '리뷰 작성자를 입력해 주세요'
      content :
        required : '설명을 입력해주세요'

    submitHandler: (form, validator) ->
      qna =
        title : $('#title').val()
        portfolioId : $('#portfolio-select').val()
        email : Meteor.user().emails[0].address
        productId : $('#product-select').val()
        reviewWriter : $('#writer').val()
        content : $('#content').val()
        type : '리뷰 이의제기'

      Meteor.call 'qnas.insert', qna, instance.designerId.get(), (error, result)->
        if error
          console.log error
        else
          swal "성공", "리뷰 문의가 완료되었습니다.", "success"

Template.complainReview.events

  'click #submit-button' : (e, t) ->
    $('#complaninReview-form').submit()

  'change #portfolio-select' : (e, t) ->
    t.portfolioId.set $(e.currentTarget).val()

Template.complainReview.helpers

  portfolios : ->
    Portfolios.find(designerId : Template.instance().designerId.get())

  products : ->
    Products.find(portfolioId : Template.instance().portfolioId.get())