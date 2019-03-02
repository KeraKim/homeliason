require './applyEvent.tpl.jade'

Template.applyEvent.onCreated ->
  @designerId = new ReactiveVar ''

#  @subscribe 'designer.products', Meteor.userId()
  @portfolioId = new ReactiveVar ''

Template.applyEvent.onRendered ->

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
      content :
        required : true
      portfolio :
        valueNotEquals : '-1'
      product :
        valueNotEquals : '-1'

    messages:
      title :
        required : '제목을 입력해 주세요'
      content :
        required : '설명을 입력해주세요'

    submitHandler: (form, validator) ->
      qna =
        title : $('#title').val()
        portfolioId : $('#portfolio-select').val()
        email : Meteor.user().emails[0].address
        productId : $('#product-select').val()
        content : $('#content').val()
        type : '이벤트 신청'

      Meteor.call 'qnas.insert', qna, instance.designerId.get(), (error, result)->
        if error
          console.log error
        else
          swal "성공", "이벤트 신청이 완료되었습니다.", "success"

Template.applyEvent.events

  'click #submit-button' : (e, t) ->
    $('#complaninReview-form').submit()

  'change #portfolio-select' : (e, t) ->
    t.portfolioId.set $(e.currentTarget).val()

Template.applyEvent.helpers

  portfolios : ->
    Portfolios.find(designerId : Template.instance().designerId.get())

  products : ->
    Products.find(portfolioId : Template.instance().portfolioId.get())