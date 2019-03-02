require './editCommission.tpl.jade'

pageInit = ->
  $(".datetimepicker").datetimepicker
#    locale: 'ko'
    format: 'YYYY-MM-DD HH:mm'


#  $('.clockpicker').clockpicker()

Template.editCommission.onCreated ->
  @state = new ReactiveDict()
  @productId = FlowRouter.getParam 'productId'
  @subscribe 'product', @productId

Template.editCommission.onRendered ->
  pageInit()

  @autorun =>
    @product = Products.findOne @productId
    if @product?
      $('#startsAt').val( moment(@product.startsAt).format('YYYY-MM-DD HH:mm') )
      $('#endsAt').val( moment(@product.endsAt).format('YYYY-MM-DD HH:mm') )
      @state.set 'isEndless', @product.isEndless
      if moment(new Date()).isBetween(@product.startsAt, @product.endsAt)
        $('#commission').val(@product.commission)
      else
        $('#commission').val(20)
  @autorun =>
    isEndless = @state.get 'isEndless'

Template.editCommission.events

  'click #isEndless': (e)->
    Template.instance().state.set 'isEndless', $('#isEndless').is(':checked')

  'click .submit': (e, t) ->
    commissionInfo =
      productId : t.productId
      startsAt : moment($('#startsAt').val()).toDate()
      endsAt : moment($('#endsAt').val()).toDate()
      isEndless : $('#isEndless').is(':checked')
      commission : Number($('#commission').val())

    Meteor.call 'product.commission.edit', commissionInfo, (error, result)->
      if error
        console.log 'error : ', error
      else
        FlowRouter.go 'products'

Template.editCommission.helpers

  commission: ->
    [0..100]

  isEndless: ->
    isEndless = Template.instance().state.get 'isEndless'
    unless isEndless
      false

    isEndless