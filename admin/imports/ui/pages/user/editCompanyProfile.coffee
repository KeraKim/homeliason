require './editCompanyProfile.tpl.jade'

{ sojaeji } = require '/imports/api/client/sojaeji.coffee'

Template.editCompanyProfile.onCreated ->

  @subscribe 'designerId', Meteor.userId()
  @designer = new ReactiveVar()
  @designerId = new ReactiveVar()
  @month = new ReactiveVar ''
  @businessLicenseUrl = new ReactiveVar ''
  @businessLicenseFileName = new ReactiveVar ''
  @bankbookImageUrl = new ReactiveVar ''
  @bankbookImageFileName = new ReactiveVar ''
  @businessType = new ReactiveVar ''


Template.editCompanyProfile.onRendered ->

#  sojaeji '서울', '강남구'

  @autorun =>
    unless Meteor.user()
      return
    if Meteor.user().profile.isManager
      @designerId.set Meteor.user().profile.designerId
      @subscribe 'designer', @designerId.get()
    else
      @designerId.set Meteor.userId()

    designer = Meteor.users.findOne @designerId.get()
    @designer.set designer
    $('#year').val(designer?.profile.foundedYear)
    $('#month').val(designer?.profile.foundedMonth)
    $('#day').val(designer?.profile.foundedDay)
#    $('#sido').val(designer?.profile.sido)
#    $('#gugun').val(designer?.profile.gugun)
    $('#firstPhoneNumber').val(designer?.profile.firstPhoneNumber)
    $('#firstMobileNumber').val(designer?.profile.firstMobileNumber)
    $('#careerYear').val(designer?.profile.careerYear)
    $('#careerMonth').val(designer?.profile.careerMonth)
    @businessLicenseUrl.set designer?.profile.businessLicenseUrl
    @businessLicenseFileName.set designer?.profile.businessLicenseFileName
    @bankbookImageUrl.set designer?.profile.bankbookImageUrl
    @bankbookImageFileName.set designer?.profile.bankbookImageFileName

    if designer?.profile.businessType isnt '프리랜서(사업자 없음)'
      @businessType.set true
    else
      @businessType.set false

  $.validator.addMethod 'valueNotEquals', ((value, element, arg) ->
    arg != value
  ), '필수로 선택하세요.'

  $('#compnay-form').validate
    rules:
#      companyName :
#        required: true
#      businessLicenseNumber :
#        required: true
#        number: true
#        rangelength: [10, 10]
      ceoName :
        required: true
      foundedYear :
        valueNotEquals : '-1'
      foundedMonth :
        valueNotEquals : '-1'
      foundedDay :
        valueNotEquals : '-1'
      email :
        required: true
        email : true
      firstFaxNumber :
        number : true
      meddleFaxNumber :
        number : true
      lastFaxNumber :
        number : true
#      businessLicenseFileName :
#        required: true
      bankbookImageFileName :
        required: true
      bankName:
        required: true
      accountName :
        required: true
      accountNumber:
        required : true
        number: true
      careerYear :
        valueNotEquals : '-1'
      careerMonth :
        valueNotEquals : '-1'
      sido :
        required: true
#      gugun :
#        required: true
      eubmyeondong :
        required: true
      phoneInput2 :
#        required: true
        number : true
#        rangelength: [3, 4]
      phoneInput3 :
#        required: true
        number : true
#        rangelength: [4, 4]
      mobileInput2 :
        required: true
        number : true
        rangelength: [3, 4]
      mobileInput3 :
        required: true
        number : true
        rangelength: [4, 4]

    messages:
#      companyName:
#        required: '필수로 입력하세요'
#      businessLicenseNumber:
#        required: '필수로 입력하세요'
#        number: '숫자만 입력해주세요'
#        rangelength : '사업자 등록번호 양식에 어긋납니다.'
#        remote : '이미 사용중인 번호 입니다.'
      ceoName :
        required: '필수로 입력하세요'
      email :
        required: '필수로 입력하세요'
        email : '이메일 형식에 맞게 입력하세요.'
      firstFaxNumber :
        number: '숫자만 입력해주세요'
      meddleFaxNumber :
        number: '숫자만 입력해주세요'
      lastFaxNumber :
        number: '숫자만 입력해주세요'
#      businessLicenseFileName :
#        required: '사업자등록증을 등록하세요'
      bankbookImageFileName :
        required: '통장사본을 등록하세요'
      bankName:
        required : '필수 입력 사항입니다.'
      accountName :
        required : '필수 입력 사항입니다.'
      accountNumber:
        required : '필수 입력 사항입니다.'
        number: '숫자로만 입력해 주세요'
      sido :
       required: '필수로 입력하세요'
#      gugun :
#       required: '필수로 입력하세요'
      eubmyeondong :
        required: '필수로 입력하세요'
      phoneInput2 :
#        required: '필수로 입력하세요'
        number : '숫자만 입력해주세요'
#        rangelength : '올바르지 않은 번호 입니다.'
      phoneInput3 :
#        required: '필수로 입력하세요'
        number : '숫자만 입력해주세요'
#        rangelength : '올바르지 않은 번호 입니다.'
      mobileInput2 :
        required: '필수로 입력하세요'
        number : '숫자만 입력해주세요'
        rangelength : '올바르지 않은 번호 입니다.'
      mobileInput3 :
        required: '필수로 입력하세요'
        number : '숫자만 입력해주세요'
        rangelength : '올바르지 않은 번호 입니다.'

    submitHandler: (form, validator) ->
      designerInfo =
        businessType : $('input:radio[name=businessType]:checked').val()
#        companyName : $('#companyName').val()
#        businessLicenseNumber : $('#businessLicenseNumber').val()
        ceoName : $('#ceoName').val()
        foundedYear : $('#year option:selected').val()
        foundedMonth : $('#month option:selected').val()
        foundedDay : $('#day option:selected').val()
        sido : $('#sido').val()
#        gugun : $('#gugun').val()
        eubmyeondong : $('#eubmyeondong').val()
        firstPhoneNumber : $('#firstPhoneNumber option:selected').val()
        meddlePhoneNumber : $('#meddlePhoneNumber').val()
        lastPhoneNumber : $('#lastPhoneNumber').val()
        firstMobileNumber : $('#firstMobileNumber option:selected').val()
        meddleMobileNumber : $('#meddleMobileNumber').val()
        lastMobileNumber : $('#lastMobileNumber').val()
        designerEmail : $('#designerEmail').val()
        firstFaxNumber : $('#firstFaxNumber').val()
        meddleFaxNumber : $('#meddleFaxNumber').val()
        lastFaxNumber : $('#lastFaxNumber').val()
#        businessLicenseUrl : Template.instance().businessLicenseUrl.get()
#        businessLicenseFileName : Template.instance().businessLicenseFileName.get()
        bankbookImageUrl : Template.instance().bankbookImageUrl.get()
        bankbookImageFileName : Template.instance().bankbookImageFileName.get()
        bankName : $('#bankName').val()
        accountName : $('#accountName').val()
        accountNumber : $('#accountNumber').val()
        careerYear : $('#careerYear option:selected').val()
        careerMonth : $('#careerMonth option:selected').val()

      if designerInfo.businessType isnt '프리랜서(사업자 없음)'
        designerInfo.companyName = $('#companyName').val()
        designerInfo.businessLicenseNumber = $('#businessLicenseNumber').val()
        designerInfo.businessLicenseUrl = Template.instance().businessLicenseUrl.get()
        designerInfo.businessLicenseFileName = Template.instance().businessLicenseFileName.get()

      Meteor.call 'designer.businessLicenseNumber.exists', designerInfo.businessLicenseNumber, designerInfo.businessType, (error, result) ->
        if error
          console.log 'error ', error
        else
          if result
            swal "저장 실패", "이미 사용중인 사업자 등록번호 입니다", "error"
            return
          else
            swal
              title: "정보변경"
              text: "기본정보를 변경하시면 디자이너 권한이 정지되고 강제 로그아웃 됩니다. 이후 심사를 거쳐 승인되면 다시 관리자 페이지에 로그인할 수 있습니다. 그래도 진행하시겠습니까?"
              type: "warning"
              showCancelButton: true
              cancelButtonText: '취소'
        #      confirmButtonColor: "#DD6B55"
              confirmButtonText: "예"
              closeOnConfirm: false
              html: false
            , ->
              Meteor.call 'designer.editDesignerInfo', designerInfo, (error, result) ->
                if error
                  console.log 'error ', error
                else
                  swal
                    title : "성공"
                    text : "기본정보 변경요청이 완료되었습니다. 승인이 완료되면 사이트 관리자가 이메일로 안내해 드립니다. 감사합니다."
                    type :"success"
                  , ->
                     Meteor.logout()
                     FlowRouter.go 'login'

Template.editCompanyProfile.events

  'click input:radio[name=businessType]': (e, t) ->
    businessType = $('input:radio[name=businessType]:checked').val()

    if businessType isnt '프리랜서(사업자 없음)'
      t.businessType.set true
    else
      t.businessType.set false

  'click #sido, click #gugun' : (e, t) ->
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
      document.getElementById('sido').value = data.address
      #5자리 새우편번호 사용
#      document.getElementById('gugun').value = data.sigungu
      # 커서를 상세주소 필드로 이동한다.
      document.getElementById('eubmyeondong').focus()
      return
    ).open()

  'change .selectMonth' : (e, t) ->
    Template.instance().month.set $('.selectMonth').val()

  'click #businessLicenseFileName' : (e, t) ->
    $('#businessLicenseFile').trigger('click')

  'click #bankbookImageFileName' : (e, t) ->
    $('#bankbookImageUrl').trigger('click')

  'change #businessLicenseFile' : (e, t) ->
    file = $("#businessLicenseFile").get(0).files[0]
    instance =  Template.instance()

    fileUploader.send file, (err, downloadUrl) ->
      if err
        console.log "error", err
      else
        instance.businessLicenseUrl.set downloadUrl
        instance.businessLicenseFileName.set file.name
        $('#businessLicenseFileName').val(file.name)

  'change #bankbookImageUrl' : (e, t) ->
    file = $("#bankbookImageUrl").get(0).files[0]
    instance =  Template.instance()

    fileUploader.send file, (err, downloadUrl) ->
      if err
        console.log "error", err
      else
        instance.bankbookImageUrl.set downloadUrl
        instance.bankbookImageFileName.set file.name
        $('#bankbookImageFileName').val(file.name)

  'click #submit-button' : (e, t) ->
    $('#compnay-form').submit()

Template.editCompanyProfile.helpers

  designer : ->
    Template.instance().designer.get()

  radioCheck : (text) ->
    businessType = Template.instance().designer.get()?.profile.businessType
    if businessType is text
      'checked'
    else
      ''

  foundedDate: (text) ->
    if text is 'year'
      currentYear = new Date().getFullYear()
      [currentYear..currentYear-100]
    else if text is 'month'
      [1..12]

  foundedDate2: ->
    month = Template.instance().month.get()
    switch month
      when '' then [1..31]
      when '2' then [1..28]
      when '1', '3', '5', '7', '8', '10', '12' then [1..31]
      else [1..30]

  careerDate: (text) ->
    if text is 'year'
      [0..50]
    else if text is 'month'
      [0..11]

  businessType: ->
    Template.instance().businessType.get()
