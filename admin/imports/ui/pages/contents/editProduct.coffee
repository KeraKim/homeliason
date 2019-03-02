require './editProduct.tpl.jade'

pageInit = ->
  $('#detailInfo').summernote
    height: 300
#  $('#detailInfo').froalaEditor
#    height: 300

dataURItoBlob = (dataURI) ->

  byteString = atob(dataURI.split(',')[1])

  mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0]

  ab = new ArrayBuffer(byteString.length)
  ia = new Uint8Array(ab)
  i = 0
  while i < byteString.length
    ia[i] = byteString.charCodeAt(i)
    i++
  new Blob([ ab ], type: mimeString)

Template.editProduct.onCreated ->
  @imageUrl = new ReactiveVar []
  @product = new ReactiveVar ''
  @isUnlimited = new ReactiveVar ''
  @productId = FlowRouter.getParam 'id'
  @designerId = new ReactiveVar ''
  @editMode = false

  if @productId
    @editMode = true
    @subscribe 'product', @productId

Template.editProduct.onRendered ->
  pageInit()

  @autorun =>
    unless Meteor.user()
      return
    if Meteor.user().profile.isManager
      @designerId.set Meteor.user().profile.designerId
      @subscribe 'designer.portfolios', @designerId.get() # 상품에서 포트폴리오 선택하는 부분을 위해
    else
      @designerId.set Meteor.userId()
      @subscribe 'designer.portfolios', Meteor.userId() # 상품에서 포트폴리오 선택하는 부분을 위해

  if @editMode
    @autorun =>
      @product.set Products.findOne @productId
      @imageUrl.set @product.get()?.imageUrl
      $('#portfolio').val(@product.get()?.portfolioId)
      $('#workDay').val(@product.get()?.workDurationInDay)
      $('#workHour').val(@product.get()?.possibleWorkPerDay)
#      $('#detailInfo').froalaEditor('html.set', @product.get()?.detailInfo )
      $('#detailInfo').summernote 'code', @product.get()?.detailInfo
      @isUnlimited.set @product.get()?.isUnlimited


  $.validator.addMethod 'valueNotEquals', ((value, element, arg) ->
    arg != value
  ), '포트폴리오를 선택해 주세요.'

  instance = Template.instance()

  $('#product-form').validate
    rules:
      portfolio:
        valueNotEquals: '0'
      price :
        required: true
        number : true
      title:
        required: true
      simpleInfo :
        required: true
      productSummary :
        required: true

    messages:
      price :
        required: '가격을 입력해 주세요'
        number : '숫자로만 입력해 주세요'
      title:
        required: '제목은 필수 입력사항 입니다.'
      simpleInfo :
        required: '간단 설명은 필수 입력사항 입니다.'
      productSummary :
        required: '상품 개요는 필수 입력사항 입니다.'

    submitHandler: (form, validator) ->

      content =
        portfolioId : $('#portfolio').val()
        portfolioName : $("#portfolio option:checked").text()
        price : $('#price').val()
        title : $('#title').val()
        onOfflineType : $('input[name="radio1"]:checked').val()
        workDurationInDay : $('#workDay').val()
        possibleWorkPerDay : $('#workHour').val()
        isUnlimited : $('#isUnlimited').is(':checked')
        isOfflineServiceInfo : $('#isOfflineServiceInfo').is(':checked')
        isFurnitureStyling : $('#isFurnitureStyling').is(':checked')
        isFabricStyling : $('#isFabricStyling').is(':checked')
        simpleInfo : $('#simple').val()
        productSummary : $('#productSummary').val()
#        detailInfo : $('#detailInfo').froalaEditor('html.get')
        detailInfo : $('#detailInfo').val()
        imageUrl : instance.imageUrl.get()

      if content.detailInfo is ''
        swal "설명 미입력", "설명은 필수 입력사항 입니다.", "error"
        return
      if content.imageUrl.length is 0
        swal "이미지 미선택", "하나 이상의 이미지를 업로드 해주세요", "error"
        return

      if instance.editMode
        Meteor.call 'products.edit',instance.productId, content, (error, result)->
          if error
            console.log error
          else
              FlowRouter.go 'products'
      else
        Meteor.call 'products.add', content, instance.designerId.get(), (error, result)->
          if error
            console.log error
          else
              FlowRouter.go 'products'

Template.editProduct.events

  'change #inputImage': (e, t)->

    for file in $("#inputImage").get(0).files

      Resizer.resize file, {
        width: 825
        height: 825
        cropSquare: false
      }, (error, file) ->
        console.log 'file : ', file
        uploader = new Slingshot.Upload("imageUpload")
        uploader.send file, (err, downloadUrl) ->
          if err
            console.log "error : ", err
          else
            console.log 'downloadUrl : ', downloadUrl

            img = new Image

            img.onload = ->

              if @width < 500
                swal '부적합한 사이즈', '권장사이즈는 4:3 비율에 가로 825px 이상되는 사진입니다.', 'warning'
                return
              else if @width >= 500
                array = t.imageUrl.get()
                array.push downloadUrl
                t.imageUrl.set array

            img.src = downloadUrl




#    for file in $("#inputImage").get(0).files
#
##      file = $("#inputImage").get(0).files[0]
#
#      _URL = window.URL or window.webkitURL
#      img = new Image
#
#      instance = Template.instance()
#
#      img.onload = ->
#
#        width = 825
#        height = Math.round(@height * width / @width)
#
#        canvas = document.createElement 'canvas'
#        canvas.width = width
#        canvas.height = height
#        ctx = canvas.getContext '2d'
#        ctx.drawImage img, 0, 0, width, height
#
#        resizeFile = dataURItoBlob(canvas.toDataURL 'image/png')
#
#        uploader = new Slingshot.Upload("imageUpload")
#        uploader.send resizeFile, (err, downloadUrl) ->
#          if err
#            console.log "error : ", err
#          else
#            console.log 'downloadUrl : ', downloadUrl
#            array = instance.imageUrl.get()
#            array.push downloadUrl
#            instance.imageUrl.set array
#
#      img.src = _URL.createObjectURL(file)

  'click #deleteImage': (e, t) ->
    Template.instance().imageUrl.set []

  'click #submit-button': (e, t) ->
    $(e.currentTarget).parents('form').submit()

  'click #isUnlimited': (e)->
    Template.instance().isUnlimited.set $('#isUnlimited').is(':checked')

  'click #deleteOneImage': (e, t) ->
    index = $(e.currentTarget).attr('index')
    imageUrlArray = t.imageUrl.get()
    imageUrlArray.splice(index, 1)
    t.imageUrl.set imageUrlArray

Template.editProduct.helpers
  imageUrl: ->
    Template.instance().imageUrl.get()
#
  product: (text) ->
    Template.instance().product.get()?[text]

  isUnlimited : ->
    Template.instance().isUnlimited.get()

  isOfflineServiceInfo : ->
    Template.instance().product.get()?.isOfflineServiceInfo

  isFurnitureStyling : ->
    Template.instance().product.get()?.isFurnitureStyling

  isFabricStyling : ->
    Template.instance().product.get()?.isFabricStyling

  radioOnline : ->
    onOfflineType = Template.instance().product.get()?.onOfflineType
    if onOfflineType is 'online' then  'checked' else ''

  radioOffline : ->
    onOfflineType = Template.instance().product.get()?.onOfflineType
    if onOfflineType is 'offline' then 'checked' else ''

  portfolios : ->
    Portfolios.find
      designerId : Template.instance().designerId.get()
      isActive : true
      isVisible : true

  workDay : ->
    [1..30]

  workHour : ->
    [1..30]



