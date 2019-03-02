require './A303_payment.tpl.jade'
require './component/fabricStyling.coffee'
require './component/furnitureStyling.coffee'
{ bucket } = require '/imports/ui/pages/bucket.coffee'
{ Page } = require '/imports/api/client/common.coffee'

IMP = undefined

Template.A303_payment.onCreated ->

  @productId = FlowRouter.getParam 'productId'
  @designerId = FlowRouter.getParam 'designerId'
  @portfolioId = FlowRouter.getParam 'portfolioId'
  @subscribe 'product', @productId
  @product = new ReactiveVar ''
  @placeInfoFileUrl1 = new ReactiveVar ''
  @placeInfoFileUrl2 = new ReactiveVar ''
  @placeInfoFileUrl3 = new ReactiveVar ''
  @placeInfoFileUrl4 = new ReactiveVar ''
  @placeInfoFileUrl5 = new ReactiveVar ''

  @likeImageFileUrl1 = new ReactiveVar ''
  @likeImageFileUrl2 = new ReactiveVar ''
  @likeImageFileUrl3 = new ReactiveVar ''
  @likeImageFileUrl4 = new ReactiveVar ''
  @likeImageFileUrl5 = new ReactiveVar ''


  @furnitureCount =  new ReactiveVar(1)
  @furnitureArray = new ReactiveVar []
  @fabricCount = new ReactiveVar(1)
  @fabricArray = new ReactiveVar []
  @isFormInfoDone = true


Template.A303_payment.onRendered ->

  ga 'require', 'ecommerce'

  @autorun =>
    product = Products.findOne(@productId)
    if product?
      @product.set product

  @autorun =>
    if Meteor.user()?.profile?.formInfo?
      if @isFormInfoDone
        formInfo = Meteor.user().profile.formInfo
        if formInfo.furnitureArray
          @furnitureCount.set formInfo.furnitureArray.length
        if formInfo.fabricArray
          @fabricCount.set formInfo.fabricArray.length

  @autorun =>
    if @subscriptionsReady()
      Tracker.afterFlush =>
        if Meteor.user()?.profile?.formInfo?
          if @isFormInfoDone
            formInfo = Meteor.user().profile.formInfo
            $('#mobile').val(formInfo.mobile)
            $('.placeInfoTextInput1').val(formInfo.placeInfoFileName1)
            @placeInfoFileUrl1.set formInfo.placeInfoFileUrl1
            $('.placeInfoTextInput2').val(formInfo.placeInfoFileName2)
            @placeInfoFileUrl2.set formInfo.placeInfoFileUrl2
            $('.placeInfoTextInput3').val(formInfo.placeInfoFileName3)
            @placeInfoFileUrl3.set formInfo.placeInfoFileUrl3
            $('.placeInfoTextInput4').val(formInfo.placeInfoFileName4)
            @placeInfoFileUrl4.set formInfo.placeInfoFileUrl4
            $('.placeInfoTextInput5').val(formInfo.placeInfoFileName5)
            @placeInfoFileUrl5.set formInfo.placeInfoFileUrl5


            $('.likeImageTextInput1').val(formInfo.likeImageFileName1)
            @likeImageFileUrl1.set formInfo.likeImageFileUrl1
            $('.likeImageTextInput2').val(formInfo.likeImageFileName2)
            @likeImageFileUrl2.set formInfo.likeImageFileUrl2
            $('.likeImageTextInput3').val(formInfo.likeImageFileName3)
            @likeImageFileUrl3.set formInfo.likeImageFileUrl3
            $('.likeImageTextInput4').val(formInfo.likeImageFileName4)
            @likeImageFileUrl4.set formInfo.likeImageFileUrl4
            $('.likeImageTextInput5').val(formInfo.likeImageFileName5)
            @likeImageFileUrl5.set formInfo.likeImageFileUrl5

            if formInfo.isOfflineServiceInfo
              $('#zipcode').val(formInfo.zipcode)
              $('#sido').val(formInfo.sido)
              $('#gugun').val(formInfo.gugun)
              $('#size_pyung').val(formInfo.size_pyung)
              $('#size_meter').val(formInfo.size_meter)
              $('#roomCount').val(formInfo.roomCount)
              $('#bathCount').val(formInfo.bathCount)
              $('#offlineServiceOtherRequest').val(formInfo.offlineServiceOtherRequest)
              if formInfo.requestPlace.length > 0
                for requestPlace in formInfo.requestPlace
                  $('.offlineServiceInput[name="'+requestPlace+'"]').closest('.james.checkbox').addClass('checked')
                  $('.offlineServiceInput[name="'+requestPlace+'"]').attr('checked', 'checked')

            if formInfo.isFurnitureStyling
              i = 0
              for furniture in formInfo.furnitureArray
                furnitureBox = $('.furnitureBox[index="'+i+'"]')
                furnitureBox.find('input').removeAttr('checked')
                furnitureBox.find('.radio-option').removeClass('checked')
                furnitureBox.find('.room').val(furniture.room)
                furnitureBox.find('.desk-div').find('input[value="'+furniture.desk+'"]').attr('checked', 'checked')
                furnitureBox.find('.desk-div').find('input[value="'+furniture.desk+'"]').closest('.radio-option').addClass('checked')
                furnitureBox.find('.chair-div').find('input[value="'+furniture.chair+'"]').attr('checked', 'checked')
                furnitureBox.find('.chair-div').find('input[value="'+furniture.chair+'"]').closest('.radio-option').addClass('checked')
                furnitureBox.find('.table-div').find('input[value="'+furniture.table+'"]').attr('checked', 'checked')
                furnitureBox.find('.table-div').find('input[value="'+furniture.table+'"]').closest('.radio-option').addClass('checked')
                furnitureBox.find('.chest-div').find('input[value="'+furniture.chest+'"]').attr('checked', 'checked')
                furnitureBox.find('.chest-div').find('input[value="'+furniture.chest+'"]').closest('.radio-option').addClass('checked')
                furnitureBox.find('.sofa-div').find('input[value="'+furniture.sofa+'"]').attr('checked', 'checked')
                furnitureBox.find('.sofa-div').find('input[value="'+furniture.sofa+'"]').closest('.radio-option').addClass('checked')
                furnitureBox.find('.bed-div').find('input[value="'+furniture.bed+'"]').attr('checked', 'checked')
                furnitureBox.find('.bed-div').find('input[value="'+furniture.bed+'"]').closest('.radio-option').addClass('checked')
                furnitureBox.find('.desk-div').find('input[value="'+furniture.desk+'"]').attr('checked', 'checked')
                furnitureBox.find('.desk-div').find('input[value="'+furniture.desk+'"]').closest('.radio-option').addClass('checked')
                furnitureBox.find('.otherRequest').val(furniture.furnitureStylingOtherRequest)
                furnitureBox.find('.agent-div').find('input[value="'+furniture.agent+'"]').attr('checked', 'checked')
                furnitureBox.find('.agent-div').find('input[value="'+furniture.agent+'"]').closest('.radio-option').addClass('checked')
                furnitureBox.find('.partBuild-div').find('input[value="'+furniture.partBuild+'"]').attr('checked', 'checked')
                furnitureBox.find('.partBuild-div').find('input[value="'+furniture.partBuild+'"]').closest('.radio-option').addClass('checked')
                i++

            if formInfo.isFabricStyling
              i = 0
              for fabric in formInfo.fabricArray
                fabricBox = $('.fabricBox[index="'+i+'"]')
                fabricBox.find('input').removeAttr('checked')
                fabricBox.find('.radio-option').removeClass('checked')
                fabricBox.find('.james.checkbox').removeClass('checked')
                fabricBox.find('.room').val(fabric.room)
                if fabric.curtainSize or fabric.curtainWindowSize
                  fabricBox.find('.curtain-div').find('input').attr('checked', 'checked')
                  fabricBox.find('.curtain-div').find('.james.checkbox').addClass('checked')
                  fabricBox.find('.curtainSize').val(fabric.curtainSize)
                  fabricBox.find('.curtainWindowSize').val(fabric.curtainWindowSize)
                if fabric.blindSize or fabric.blindWindowSize
                  fabricBox.find('.blind-div').find('input').attr('checked', 'checked')
                  fabricBox.find('.blind-div').find('.james.checkbox').addClass('checked')
                  fabricBox.find('.blindSize').val(fabric.blindSize)
                  fabricBox.find('.blindWindowSize').val(fabric.blindWindowSize)
                if fabric.otherSize or fabric.otherWindowSize
                  fabricBox.find('.other-div').find('input').attr('checked', 'checked')
                  fabricBox.find('.other-div').find('.james.checkbox').addClass('checked')
                  fabricBox.find('.otherSize').val(fabric.otherSize)
                  fabricBox.find('.otherWindowSize').val(fabric.otherWindowSize)
                fabricBox.find('.otherRequest').val(fabric.fabricStylingOtherRequest)
                fabricBox.find('input[value="'+fabric.fabricBuild+'"]').attr('checked', 'checked')
                fabricBox.find('input[value="'+fabric.fabricBuild+'"]').closest('.radio-option').addClass('checked')
                i++

            $('#otherRequest').val(formInfo.otherRequest)
            $('#visitPath').val(formInfo.visitPath)
            $('#servicePurpose').val(formInfo.servicePurpose)

            @isFormInfoDone = false

  instance = Template.instance()

  $('#payment-form').validate
    rules:
      mobile :
        required: true
        number : true
        rangelength: [9, 11]
      zipcode :
        required: true
      sido :
        required: true
      size_pyung :
        required: true
        number : true
      size_meter :
        required: true
        number : true
      roomCount :
        required: true
        number : true
      bathCount :
        required: true
        number : true

    messages:
      mobile :
        required: '전화번호를 입력해 주세요'
        number : '숫자만 입력해 주세요'
        rangelength : '전화번호 양식에 어긋납니다.'
      zipcode :
        required: '우편번호를 입력해 주세요'
      sido :
        required: '주소를 입력해 주세요'
      size_pyung :
        required: '평수를 입력해 주세요'
        number : '숫자로 입력해 주세요'
      size_meter :
        required: '미터를 입력해 주세요'
        number : '숫자로 입력해 주세요'
      roomCount :
        required: '필수값'
        number : '숫자입력'
      bathCount :
        required: '필수값'
        number : '숫자입력'

    errorPlacement: (error, element) ->
      $(element).closest('div').find('.error-text').html error

    submitHandler: (form, validator) ->

      product = Template.instance().product.get()

      #기본적으로 입력되는 폼 정보들
      formInfo =
#        homeType : $('input:radio[name=homeType]:checked').val()
        homeType : $('.homeTypeClass.checked').find('input').val()
        mobile : $('#mobile').val()
        placeInfoFileUrl1 : Template.instance().placeInfoFileUrl1.get()
        placeInfoFileUrl2 : Template.instance().placeInfoFileUrl2.get()
        placeInfoFileUrl3 : Template.instance().placeInfoFileUrl3.get()
        placeInfoFileUrl4 : Template.instance().placeInfoFileUrl4.get()
        placeInfoFileUrl5 : Template.instance().placeInfoFileUrl5.get()
        likeImageFileUrl1 : Template.instance().likeImageFileUrl1.get()
        likeImageFileUrl2 : Template.instance().likeImageFileUrl2.get()
        likeImageFileUrl3 : Template.instance().likeImageFileUrl3.get()
        likeImageFileUrl4 : Template.instance().likeImageFileUrl4.get()
        likeImageFileUrl5 : Template.instance().likeImageFileUrl5.get()
        otherRequest : $('#otherRequest').val()
        visitPath : $('#visitPath option:selected').val()
        servicePurpose : $('#servicePurpose option:selected').val()

      #상품이 오프라인 서비스일때만 들어가는 정보들
      if product.isOfflineServiceInfo
        formInfo.zipcode = $('#zipcode').val()
        formInfo.sido = $('#sido').val()
        formInfo.gugun = $('#gugun').val()
        formInfo.size_pyung = $('#size_pyung').val()
        formInfo.size_meter = $('#size_meter').val()
        formInfo.roomCount = $('#roomCount').val()
        formInfo.bathCount = $('#bathCount').val()
        formInfo.isOfflineServiceInfo = true

        RequestArray = []
        $('.offlineServiceInput').each (index, item) ->
          checked = $(item).attr('checked')
          if checked
            RequestArray.push $(item).attr('name')

        formInfo.requestPlace = RequestArray
        formInfo.offlineServiceOtherRequest = $('#offlineServiceOtherRequest').val()

      if product.isFurnitureStyling
        instance.furnitureArray.set []
        $('.furnitureBox').each (index, item) ->
          furnitureBox =
            room : $(item).find('.room').val()
            desk : $(item).find('.desk-div .checked input').val()
            chair : $(item).find('.chair-div .checked input').val()
            table : $(item).find('.table-div .checked input').val()
            chest : $(item).find('.chest-div .checked input').val()
            sofa : $(item).find('.sofa-div .checked input').val()
            bed : $(item).find('.bed-div .checked input').val()
            furnitureStylingOtherRequest : $(item).find('.otherRequest').val()
            agent : $(item).find('.agent-div .checked input').val()
            partBuild : $(item).find('.partBuild-div .checked input').val()
#            room : $(item).find('.room option:selected').val()
#            desk : $(item).find('input:radio[item=desk]:checked').val()
#            chair : $(item).find('input:radio[item=chair]:checked').val()
#            table : $(item).find('input:radio[item=table]:checked').val()
#            chest : $(item).find('input:radio[item=chest]:checked').val()
#            sofa : $(item).find('input:radio[item=sofa]:checked').val()
#            bed : $(item).find('input:radio[item=bed]:checked').val()
#            furnitureStylingOtherRequest : $(item).find('.otherRequest').val()
#            agent : $(item).find('input:radio[item=agent]:checked').val()
#            partBuild : $(item).find('input:radio[item=partBuild]:checked').val()
          furnitureArray = instance.furnitureArray.get()
          furnitureArray.push furnitureBox
          instance.furnitureArray.set furnitureArray
        formInfo.isFurnitureStyling = true
        furnitureArray = instance.furnitureArray.get()
        formInfo.furnitureArray = furnitureArray

      if product.isFabricStyling
        instance.fabricArray.set []
        $('.fabricBox').each (index, item) ->
          fabricBox =
            room : $(item).find('.room option:selected').val()
            fabricStylingOtherRequest : $(item).find('.otherRequest').val()
            fabricBuild : $(item).find('.fabricBuild-div .checked input').val()
          if $(item).find('.curtain').attr('checked')
            fabricBox.curtainSize = $(item).find('.curtainSize').val()
            fabricBox.curtainWindowSize = $(item).find('.curtainWindowSize').val()
          if $(item).find('.blind').attr('checked')
            fabricBox.blindSize = $(item).find('.blindSize').val()
            fabricBox.blindWindowSize = $(item).find('.blindWindowSize').val()
          if $(item).find('.other').attr('checked')
            fabricBox.otherSize = $(item).find('.otherSize').val()
            fabricBox.otherWindowSize = $(item).find('.otherWindowSize').val()
          fabricArray = instance.fabricArray.get()
          fabricArray.push fabricBox
          instance.fabricArray.set fabricArray
        formInfo.isFabricStyling = true
        fabricArray = instance.fabricArray.get()
        formInfo.fabricArray = fabricArray

      IMP = window.IMP
      IMP.init('imp71921105')

      pay_method = $('.pay_method option:selected').val()
      product = instance.product.get()
      user = Meteor.user()

      IMP.request_pay {
        pg : 'html5_inicis'
        pay_method: pay_method
        merchant_uid: 'merchant_' + (new Date).getTime()
#        escrow : true
        name: product.title
        amount: product.price
        buyer_email: user.emails[0].address
        buyer_name: user.profile.userName
        buyer_tel: $('#mobile').val()
        vbank_due : moment(moment(new Date()).add(7, 'day')).format('YYYYMMDDhhmm')
      }, (rsp) ->
        msg
        if rsp.success
          msg = '결제가 완료되었습니다.'
          msg += '고유ID : ' + rsp.imp_uid
          msg += '상점 거래ID : ' + rsp.merchant_uid
          msg += '결제 금액 : ' + rsp.paid_amount
          msg += '카드 승인번호 : ' + rsp.apply_num
          msg += '결제 상태 : ' + rsp.status
          msg += '주문자 이름 : ' + rsp.buyer_name
          msg += '주문자 Email : ' + rsp.buyer_email

          console.log msg

          #작업 날짜를 계산하는 부분
          date = moment(FlowRouter.getQueryParam('reserveDate')).utc().format('YYYY-MM-DD')
          workDurationInDayArray = []
          i = 0
          while i < product.workDurationInDay
            workDurationInDayArray.push moment(date).add(i+1, 'days').toDate()
            i++

          commission = 20
          product = instance.product.get()
          portfolio = Portfolios.findOne instance.portfolioId
          designer = Meteor.users.findOne instance.designerId
          if product.startsAt < new Date() and product.endsAt > new Date()
            commission = product.commission

          #결제와 관련된 정보들
          paymentInfo =
            userId : Meteor.userId()
            designerId : instance.designerId
            portfolioId : instance.portfolioId
            productId : instance.productId
            imp_uid : rsp.imp_uid # 아임포트 거래 고유 번호
            merchant_uid : rsp.merchant_uid # 가맹점에서 생성/관리하는 고유 주문번호
            pay_method : rsp.pay_method # 결제 수단
            price : rsp.paid_amount # 결제 금액
            vbank_num : rsp.vbank_num #가상계좌 번호
            vbank_name : rsp.vbank_name #가상계좌 은행명
            vbank_date : rsp.vbank_date #가상계좌 입금기한
            detail : formInfo
            commission : commission #수수료율
            effectiveDays : workDurationInDayArray
            buyerName : Meteor.user().profile.userName
            buyerEmail : Meteor.user().emails[0].address
            productTitle : product.title
            portfolioTitle : portfolio.title
            designerName : designer.profile.designerName

          Meteor.call 'payment.add', paymentInfo, (error, saleId)->
            if error
              console.log error
            else
              console.log 'saleId : ', saleId

              length = workDurationInDayArray.length

              mailDateObject = {
                templateName : '[홈리에종] 상품을 구매해주셔서 감사합니다.',
                content1 : portfolio.title,
                content2 : product.title,
                content3 : designer.profile.designerName,
                content4 : $('#mobile').val(),
                content5 : Meteor.user().profile.userName,
                content6 : moment(workDurationInDayArray[0]).format('YYYY-MM-DD'),
                content7 : moment(workDurationInDayArray[length - 1]).format('YYYY-MM-DD')
              }

              Meteor.call 'mandrill', Meteor.user().emails[0].address, Meteor.user().profile.userName, '[홈리에종] 상품을 구매해주셔서 감사합니다.', mailDateObject, (error, result) ->
                if error
                  console.log error
                else
                  console.log result

              Meteor.call 'aligo', '[홈리에종]\n 안녕하세요! 나만의 디자이너를 만나볼 수 있는 홈리에종입니다:) '+ portfolio.title +' 포트폴리오의 '+ product.title +'상품을 구매해 주셔서 감사합니다. '+ designer.profile.designerName +'디자이너가 직접 연락드릴 예정 입니다. 서비스 시작일은 '+ workDurationInDayArray[0] +' 이고, 서비스 종료일은 '+ workDurationInDayArray[length - 1] +' 입니다. 고객님의 구매내역은 홈리에종 홈페이지 로그인 후 개인페이지의 구매내역에서 확인가능합니다. http://home-liaison.com', $('#mobile').val(), (error, result)->
                if error
                  console.log error
                else
                  console.log result

              mailDateObject = {
                templateName : '[홈리에종] 상품이 판매되었습니다.',
                content1 : portfolio.title,
                content2 : product.title,
                content3 : Meteor.user().profile.userName
              }

              firstMobileNumber = designer.profile.firstMobileNumber
              meddleMobileNumber = designer.profile.meddleMobileNumber
              lastMobileNumber = designer.profile.lastMobileNumber
              mobile = firstMobileNumber.concat(meddleMobileNumber, lastMobileNumber)

              Meteor.call 'mandrill', designer.emails[0].address, designer.profile.userName, '[홈리에종] 상품이 판매되었습니다.', mailDateObject, (error, result) ->
                if error
                  console.log error
                else
                  console.log result

              Meteor.call 'aligo', '[홈리에종]\n '+portfolio.title+'포트폴리오 '+product.title+'상품이 판매되었습니다. '+Meteor.user().profile.userName+'고객님과 커뮤니케이션 후 서비스 일정에 따라 진행하시면 됩니다. http://home-liaison.com', mobile, (error, result)->
                          if error
                            console.log error
                          else
                            console.log result

              sendGAEcommerce(saleId, rsp.paid_amount, product.title)
              FlowRouter.go 'result', { pageName : 'payment' }

#          #스케쥴 스키마 정보를 만드는 부분
#          schedule =
#            designerId : instance.designerId
#            portfolioId : instance.portfolioId
#            productId : instance.productId
#            effectiveDays : workDurationInDayArray
#
#          Meteor.call 'payment.add', paymentInfo, schedule, (error)->
#            if error
#              console.log error
#            else
#              console.log 'success'

        else
          msg = '결제에 실패하였습니다.'
          msg += '에러내용 : ' + rsp.error_msg
          console.log msg
          sweetAlert "결제 실패", "결제에 실패하였습니다", "error"
        return

sendGAEcommerce = (transactionId, price, title)->
#  name = ''
#  revenue = ''
#  tax = ''
#  switch price
#    when '33,000'
#      name = '삼만원'
#      revenue = '30000'
#      tax = '3000'
#    when '55,000'
#      name = '오만원'
#      revenue = '50000'
#      tax = '5000'

  #TODO result (saleId)를 ga의 transactionID로 사용
  ga 'ecommerce:addTransaction',
    'id': transactionId
    'revenue': price
    'tax': price * 0.1
  ga 'ecommerce:addProduction',
    'id': transactionId
#    'name': price + '만원'
    'name': title
    'price': price
    'quantity': '1'
  ga 'ecommerce:send'

Template.A303_payment.events

  'keyup #size_pyung': (e, t) ->
    if (/^[0-9]+$/.test($('#size_pyung').val()))
      $('#size_meter').val($('#size_pyung').val() * 3.3058)

    if $('#size_pyung').val() is ''
      $('#size_meter').val('')

  'keyup #size_meter': (e, t) ->
    if (/^[0-9.]+$/.test($('#size_meter').val()))
      pyung = $('#size_meter').val() * 0.3025
      $('#size_pyung').val(parseInt(pyung))

    if $('#size_meter').val() is ''
      $('#size_pyung').val('')

  'click .furnitureAdd-button': (e, t) ->
    count = t.furnitureCount.get()
    count += 1
    t.furnitureCount.set count

  'click .furnitureDelete-button': (e, t) ->
    $(e.currentTarget).closest('.furnitureBox').remove()

  'click .fabricAdd-button': (e, t) ->
    count = t.fabricCount.get()
    count += 1
    t.fabricCount.set count

  'click .fabricDelete-button': (e, t) ->
    $(e.currentTarget).closest('.fabricBox').remove()

  'click .james.checkbox': (e, t) ->
    $this = $(e.currentTarget).toggleClass('checked')

    if $this.hasClass('checked')
      $this.children('input').attr 'checked', 'checked'

    else
      $this.children('input').removeAttr 'checked'

  'click .placeInfo-btn' : (e, t) ->
    name = $(e.currentTarget).attr('name')
    $('#'+name).trigger('click')

  'change .placeInfo-file' : (e, t) ->
#    file = $("#placeInfo-file").get(0).files[0]
    file = $(e.currentTarget).get(0).files[0]
    index = $(e.currentTarget).attr('index')
    instance =  Template.instance()

    fileUploader.send file, (err, downloadUrl) ->
      if err
        console.log "error", err
      else
        switch index
          when '1' then instance.placeInfoFileUrl1.set downloadUrl
          when '2' then instance.placeInfoFileUrl2.set downloadUrl
          when '3' then instance.placeInfoFileUrl3.set downloadUrl
          when '4' then instance.placeInfoFileUrl4.set downloadUrl
          when '5' then instance.placeInfoFileUrl5.set downloadUrl
        $(e.currentTarget).closest('.input-with-label').find('.placeInfoTextInput').val(file.name)

  'click .likeImage-btn' : (e, t) ->
    name = $(e.currentTarget).attr('name')
    $('#'+name).trigger('click')

  'change .likeImage-file' : (e, t) ->
    file = $(e.currentTarget).get(0).files[0]
    index = $(e.currentTarget).attr('index')
    instance =  Template.instance()

    fileUploader.send file, (err, downloadUrl) ->
      if err
        console.log "error", err
      else
        switch index
          when '1' then instance.likeImageFileUrl1.set downloadUrl
          when '2' then instance.likeImageFileUrl2.set downloadUrl
          when '3' then instance.likeImageFileUrl3.set downloadUrl
          when '4' then instance.likeImageFileUrl4.set downloadUrl
          when '5' then instance.likeImageFileUrl5.set downloadUrl
        $(e.currentTarget).closest('.input-with-label').find('.likeImageTextInput').val(file.name)

  #TODO 라디오 버튼 체크 부분분
  'click .radio-option' : (e, t) ->
    checked = $(e.currentTarget).hasClass('checked')
    name = $(e.currentTarget).find('input').attr('name')
    if !checked
      $('input[name="' + name + '"]').parent().removeClass 'checked'
      $('input[name="' + name + '"]').attr('checked', false)
      $(e.currentTarget).addClass 'checked'
      $(e.currentTarget).find('input').attr('checked', true)

  'click .address-btn' : (e, t) ->
    new (daum.Postcode)(oncomplete: (data) ->
    # 팝업에서 검색결과 항목을 클릭했을때 실행할 코드를 작성하는 부분.
    # 각 주소의 노출 규칙에 따라 주소를 조합한다.
    # 내려오는 변수가 값이 없는 경우엔 공백('')값을 가지므로, 이를 참고하여 분기 한다.
      fullAddr = ''
      # 최종 주소 변수
      extraAddr = ''
      # 조합형 주소 변수
      # 사용자가 선택한 주소 타입에 따라 해당 주소 값을 가져온다.
      if data.userSelectedType == 'R'
    # 사용자가 도로명 주소를 선택했을 경우
        fullAddr = data.roadAddress
      else
    # 사용자가 지번 주소를 선택했을 경우(J)
        fullAddr = data.jibunAddress
      # 사용자가 선택한 주소가 도로명 타입일때 조합한다.
      if data.userSelectedType == 'R'
    #법정동명이 있을 경우 추가한다.
        if data.bname != ''
          extraAddr += data.bname
        # 건물명이 있을 경우 추가한다.
        if data.buildingName != ''
          extraAddr += if extraAddr != '' then ', ' + data.buildingName else data.buildingName
        # 조합형주소의 유무에 따라 양쪽에 괄호를 추가하여 최종 주소를 만든다.
        fullAddr += if extraAddr != '' then ' (' + extraAddr + ')' else ''
      # 우편번호와 주소 정보를 해당 필드에 넣는다.
      document.getElementById('zipcode').value = data.zonecode
      #5자리 새우편번호 사용
      document.getElementById('sido').value = fullAddr
      # 커서를 상세주소 필드로 이동한다.
      document.getElementById('gugun').focus()
      return
    ).open()

  'click #pay-btn' : (e, t) ->

    terms1 = $('input[name=terms1]:checked').val()
    if terms1 is 'no'
      sweetAlert "약관 비동의", "개인정보 3자 제공에 동의해주세요", "error"
      return

    terms2 = $('input[name=terms2]:checked').val()
    if terms2 is 'no'
      sweetAlert "약관 비동의", "취소 및 환불규정에 동의해주세요", "error"
      return

    unless Meteor.userId()
      sweetAlert "로그인", "로그인 하시고 다시 시도해 주시요", "error"
      return

    unless $('.homeTypeClass.checked').find('input').val()
      sweetAlert "주거유형", "주거유형을 선택해주세요", "error"
      return

    $('#payment-form').submit()

  'click #back-btn': (e, t) ->
    history.back()

  'click input, click .radio-option, click .checkbox, click .btn, click textarea, keyup input, keyup textarea': (e, t) ->
    product = t.product.get()
    #기본적으로 입력되는 폼 정보들
    formInfo =
#      homeType : $('input:radio[name=homeType]:checked').val()
      homeType : $('.homeTypeClass.checked').find('input').val()
      mobile : $('#mobile').val()
      placeInfoFileUrl1 : Template.instance().placeInfoFileUrl1.get()
      placeInfoFileName1 : $('.placeInfoTextInput1').val()
      placeInfoFileUrl2 : Template.instance().placeInfoFileUrl2.get()
      placeInfoFileName2 : $('.placeInfoTextInput2').val()
      placeInfoFileUrl3 : Template.instance().placeInfoFileUrl3.get()
      placeInfoFileName3 : $('.placeInfoTextInput3').val()
      placeInfoFileUrl4 : Template.instance().placeInfoFileUrl4.get()
      placeInfoFileName4 : $('.placeInfoTextInput4').val()
      placeInfoFileUrl5 : Template.instance().placeInfoFileUrl5.get()
      placeInfoFileName5 : $('.placeInfoTextInput5').val()
      likeImageFileUrl1 : Template.instance().likeImageFileUrl1.get()
      likeImageFileName1 : $('.likeImageTextInput1').val()
      likeImageFileUrl2 : Template.instance().likeImageFileUrl2.get()
      likeImageFileName2 : $('.likeImageTextInput2').val()
      likeImageFileUrl3 : Template.instance().likeImageFileUrl3.get()
      likeImageFileName3 : $('.likeImageTextInput3').val()
      likeImageFileUrl4 : Template.instance().likeImageFileUrl4.get()
      likeImageFileName4 : $('.likeImageTextInput4').val()
      likeImageFileUrl5 : Template.instance().likeImageFileUrl5.get()
      likeImageFileName5 : $('.likeImageTextInput5').val()
      otherRequest : $('#otherRequest').val()
      visitPath : $('#visitPath option:selected').val()
      servicePurpose : $('#servicePurpose option:selected').val()

    #상품이 오프라인 서비스일때만 들어가는 정보들
    if product.isOfflineServiceInfo
      formInfo.zipcode = $('#zipcode').val()
      formInfo.sido = $('#sido').val()
      formInfo.gugun = $('#gugun').val()
      formInfo.size_pyung = $('#size_pyung').val()
      formInfo.size_meter = $('#size_meter').val()
      formInfo.roomCount = $('#roomCount').val()
      formInfo.bathCount = $('#bathCount').val()
      formInfo.isOfflineServiceInfo = true

      RequestArray = []
      $('.offlineServiceInput').each (index, item) ->
        checked = $(item).attr('checked')
        if checked
          RequestArray.push $(item).attr('name')

      formInfo.requestPlace = RequestArray
      formInfo.offlineServiceOtherRequest = $('#offlineServiceOtherRequest').val()

    if product.isFurnitureStyling
      t.furnitureArray.set []
      $('.furnitureBox').each (index, item) ->
#        console.log 'index : ', index
#        console.log 'item : ', item
        console.log 'room : ', $(item).find('.room').val()
        furnitureBox =
          room : $(item).find('.room').val()
          desk : $(item).find('.desk-div .checked input').val()
          chair : $(item).find('.chair-div .checked input').val()
          table : $(item).find('.table-div .checked input').val()
          chest : $(item).find('.chest-div .checked input').val()
          sofa : $(item).find('.sofa-div .checked input').val()
          bed : $(item).find('.bed-div .checked input').val()
          furnitureStylingOtherRequest : $(item).find('.otherRequest').val()
          agent : $(item).find('.agent-div .checked input').val()
          partBuild : $(item).find('.partBuild-div .checked input').val()
#        furnitureBox =
#          room : $(item).find('.room option:selected').val()
#          desk : $(item).find('input:radio[item=desk]:checked').val()
#          chair : $(item).find('input:radio[item=chair]:checked').val()
#          table : $(item).find('input:radio[item=table]:checked').val()
#          chest : $(item).find('input:radio[item=chest]:checked').val()
#          sofa : $(item).find('input:radio[item=sofa]:checked').val()
#          bed : $(item).find('input:radio[item=bed]:checked').val()
#          furnitureStylingOtherRequest : $(item).find('.otherRequest').val()
#          agent : $(item).find('input:radio[item=agent]:checked').val()
#          partBuild : $(item).find('input:radio[item=partBuild]:checked').val()
        furnitureArray = t.furnitureArray.get()
        furnitureArray.push furnitureBox
        t.furnitureArray.set furnitureArray
      formInfo.isFurnitureStyling = true
      furnitureArray = t.furnitureArray.get()
#      formInfo.furnitureArray = []
      formInfo.furnitureArray = furnitureArray

    if product.isFabricStyling
      t.fabricArray.set []
      $('.fabricBox').each (index, item) ->
        fabricBox =
          room : $(item).find('.room').val()
          fabricStylingOtherRequest : $(item).find('.otherRequest').val()
          fabricBuild : $(item).find('.fabricBuild-div .checked input').val()
        if $(item).find('.curtain').attr('checked')
          fabricBox.curtainSize = $(item).find('.curtainSize').val()
          fabricBox.curtainWindowSize = $(item).find('.curtainWindowSize').val()
        if $(item).find('.blind').attr('checked')
          fabricBox.blindSize = $(item).find('.blindSize').val()
          fabricBox.blindWindowSize = $(item).find('.blindWindowSize').val()
        if $(item).find('.other').attr('checked')
          fabricBox.otherSize = $(item).find('.otherSize').val()
          fabricBox.otherWindowSize = $(item).find('.otherWindowSize').val()
        fabricArray = t.fabricArray.get()
        fabricArray.push fabricBox
        t.fabricArray.set fabricArray
      formInfo.isFabricStyling = true
      fabricArray = t.fabricArray.get()
#      formInfo.fabricArray = []
      formInfo.fabricArray = fabricArray

    Meteor.call 'payment.temporaryStorage', formInfo, (error)->
      if error
        console.log error
#      else
#        console.log 'success'

Template.A303_payment.helpers

  product : ->
    Template.instance().product.get()

  onOfflineType : (type) ->
    if type is 'online'
      '온라인'
    else
      '오프라인'

  workDay : (day) ->
    if day isnt '0'
      day + '일'

  workHour : (hour) ->
    if hour isnt '0'
      hour + '시간'

  productSummary : ->
    unless Template.instance().product.get()
      return
    Template.instance().product.get().productSummary.split('\n')

  comma: (price) ->
    Page.comma(price)

  furnitureCount: ->
    [1..Template.instance().furnitureCount.get()]

  fabricCount: ->
    [1..Template.instance().fabricCount.get()]

  isAddButton: (count) ->
    if count == 1
      false
    else
      true

  homeTypeRadioCheck : (text) ->
    homeType = Meteor.user()?.profile?.formInfo?.homeType
    if homeType is text
      'checked'
    else
      ''
#  offlineServiceRequestPlaceCheck: (text) ->
#    requestPlace = Meteor.user()?.profile?.formInfo?.requestPlace
#    if requestPlace?
#      if requestPlace.length > 0
#        for placeName in requestPlace
#          console.log 'placeName : ', placeName
#          if placeName is text
#            'checked'
#          else
#            ''
#        console.log 'requestPlace : ', requestPlace
#        $('[name="'+requestPlace+'"]').css('color', 'red')

  cancelNotice:(text) ->
    reserveDate = FlowRouter.getQueryParam('reserveDate')
    remainingDay = moment(reserveDate).diff(new Date(), 'days')

    ratio = 0
    if 30 <= remainingDay
      ratio = 100
    else if remainingDay < 30 and remainingDay > 21
      ratio = 90
    else if remainingDay <= 21 and remainingDay > 14
      ratio = 80
    else if remainingDay <= 14 and remainingDay > 7
      ratio = 70
    else if remainingDay <= 7 and remainingDay >= 4
      ratio = 60

    if text is 'date'
      return remainingDay
    if text is 'ratio'
      return 100 - ratio