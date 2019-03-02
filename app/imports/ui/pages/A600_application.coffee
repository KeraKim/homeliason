require './A600_application.tpl.jade'

{ sojaeji } = require '/imports/api/client/sojaeji.coffee'


Template.A600_application.onCreated ->
  @month = new ReactiveVar ''
  @businessLicenseFileUrl = new ReactiveVar ''
  @businessLicenseFileName = new ReactiveVar ''
  @bankbookImageFileUrl = new ReactiveVar ''
  @bankbookImageFileName = new ReactiveVar ''
  @businessType = new ReactiveVar(true)

Template.A600_application.onRendered ->

#  sojaeji '서울', '강남구'

  $.validator.addMethod 'valueNotEquals', ((value, element, arg) ->
    arg != value
  ), '필수로 선택하세요.'

  $.validator.addMethod 'businessLicenseNumber', ((value, element, arg) ->
    regex = new RegExp('^[0-9]+(-[0-9]+)+$')
    regex.test(value)
  ), '사업자 등록번호 양식에 어긋납니다.'

  @autorun =>
    $('#application-form').validate
      rules:
#        companyName :
#          required: true
#        businessLicenseNumber :
#          required: true
#          businessLicenseNumber : true
#          number: true
#          rangelength: [12, 12]
#          rangelength: [10, 10]
        ceoName :
          required: true
#        foundedYear :
#          valueNotEquals : '-1'
#        foundedMonth :
#          valueNotEquals : '-1'
#        foundedDay :
#          valueNotEquals : '-1'
        email :
          required: true
          email : true
        fax1 :
          number : true
        fax2 :
          number : true
        fax3 :
          number : true
#        businessLicenseFileName :
#          required: true
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
#        gugun :
#          required: true
        eubmyeondong :
          required: true
        phoneInput2 :
#          required: true
          number : true
#          rangelength: [3, 4]
        phoneInput3 :
#          required: true
          number : true
#          rangelength: [4, 4]
        mobileInput2 :
          required: true
          number : true
          rangelength: [3, 4]
        mobileInput3 :
          required: true
          number : true
          rangelength: [4, 4]

      messages:
#        companyName:
#          required: '필수 입력 사항입니다'
#        businessLicenseNumber:
#          required: '사업자 등록번호를 입력하세요'
#          number: '숫자만 입력해주세요'
#          rangelength : '사업자 등록번호 양식에 어긋납니다.'
#          remote : '이미 사용중인 번호 입니다.'
        ceoName :
          required: '필수 입력 사항입니다'
        email :
          required: '필수 입력 사항입니다'
          email : '이메일 형식에 맞게 입력하세요.'
        fax1 :
          number: '숫자만 입력해주세요'
        fax2 :
          number: '숫자만 입력해주세요'
        fax3 :
          number: '숫자만 입력해주세요'
#        businessLicenseFileName :
#          required: '사업자등록증을 등록하세요'
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
          required: '필수 입력 사항입니다'
#        gugun :
#          required: '필수 입력 사항입니다'
        eubmyeondong :
          required: '필수 입력 사항입니다'
        phoneInput2 :
#          required: '필수 입력 사항입니다'
          number : '숫자만 입력해주세요'
#          rangelength : '올바르지 않은 번호 입니다.'
        phoneInput3 :
#          required: '필수 입력 사항입니다'
          number : '숫자만 입력해주세요'
#          rangelength : '올바르지 않은 번호 입니다.'
        mobileInput2 :
          required: '필수 입력 사항입니다'
          number : '숫자만 입력해주세요'
          rangelength : '올바르지 않은 번호 입니다.'
        mobileInput3 :
          required: '필수 입력 사항입니다'
          number : '숫자만 입력해주세요'
          rangelength : '올바르지 않은 번호 입니다.'

      errorPlacement: (error, element) ->
        $(element).closest('div').find('.error-text').html error

      submitHandler: (form, validator) ->

        foundedYear = $('#foundedYear option:selected').val()
        if foundedYear is '-1'
          foundedYear = moment().get('year')
        foundedMonth = $('#foundedMonth option:selected').val()
        if foundedMonth is '-1'
          foundedMonth = (moment().get('month') + 1)
        foundedDay = $('#foundedDay option:selected').val()
        if foundedDay is '-1'
          foundedDay = moment().get('date')

        designerApplyInfo =
#          businessType : $('input:radio[name=businessType]:checked').val()
          businessType : $('.businessType .checked input').val()
#          companyName : $('#companyName').val()
#          businessLicenseNumber : $('#businessLicenseNumber').val()
          ceoName : $('#ceoName').val()
          foundedYear : foundedYear
          foundedMonth : foundedMonth
          foundedDay : foundedDay
          sido : $('#sido').val()
#          gugun : $('#gugun').val()
          eubmyeondong : $('#eubmyeondong').val()
          firstPhoneNumber : $('#phoneInput1 option:selected').val()
          meddlePhoneNumber : $('#phoneInput2').val()
          lastPhoneNumber : $('#phoneInput3').val()
          firstMobileNumber : $('#mobileInput1 option:selected').val()
          meddleMobileNumber : $('#mobileInput2').val()
          lastMobileNumber : $('#mobileInput3').val()
          designerEmail : $('#designerEmail').val()
          firstFaxNumber : $('#fax1').val()
          meddleFaxNumber : $('#fax2').val()
          lastFaxNumber : $('#fax3').val()
#          businessLicenseUrl : Template.instance().businessLicenseFileUrl.get()
#          businessLicenseFileName : Template.instance().businessLicenseFileName.get()
          bankbookImageUrl : Template.instance().bankbookImageFileUrl.get()
          bankbookImageFileName : Template.instance().bankbookImageFileName.get()
          bankName : $('#bankName').val()
          accountName : $('#accountName').val()
          accountNumber : $('#accountNumber').val()
          careerYear : $('#careerYear option:selected').val()
          careerMonth : $('#careerMonth option:selected').val()

        if designerApplyInfo.businessType isnt '프리랜서(사업자 없음)'
          designerApplyInfo.companyName = $('#companyName').val()
          designerApplyInfo.businessLicenseNumber = $('#businessLicenseNumber').val()
          designerApplyInfo.businessLicenseUrl = Template.instance().businessLicenseFileUrl.get()
          designerApplyInfo.businessLicenseFileName = Template.instance().businessLicenseFileName.get()

        Meteor.call 'users.businessLicenseNumber.exists', designerApplyInfo.businessLicenseNumber, designerApplyInfo.businessType, (error, result) ->
          if error
            console.log 'error ', error
          else
            if result
              sweetAlert "회원가입 실패", "이미 사용중인 사업자 등록번호 입니다", "error"
              return
            else
              if Meteor.user()
                Meteor.call 'user.designerApply', designerApplyInfo, (error, result) ->
                  if error
                    console.log 'error ', error
                  else
                    Meteor.call 'mandrill', Meteor.user().emails[0].address, '홈리에종 사용자님', '[홈리에종] 디자이너 신청이 완료되었습니다. 빠른 시간 내에 답변 드리겠습니다.', (error, result) ->
                      if error
                        console.log error
                      else
                        console.log result
                    FlowRouter.go 'result', { pageName : 'application' }

              else if !Meteor.user()

                designerApplyInfo = _.extend designerApplyInfo,
                  userName : designerApplyInfo.ceoName
                  isDesigner :true
                  isExternalUser : true

                user =
                  email: designerApplyInfo.designerEmail
                  password: Math.random().toString(36).slice(-8)
                  profile:
                    designerApplyInfo

                Accounts.createUser user, (error) ->
                  if error
                    if error.reason.indexOf('Email') > -1
                      sweetAlert "회원가입 실패", "이미 사용중인 이메일 입니다", "error"
                  else
                    Meteor.logout()
                    mailDateObject = {
                      templateName : '[홈리에종] 디자이너 신청이 접수되었습니다.'
                      content1 : $('#ceoName').val(),
                    }
                    Meteor.call 'mandrill', user.email, $('#ceoName').val(), '[홈리에종] 디자이너 신청이 접수되었습니다.', mailDateObject, (error, result) ->
                      if error
                        console.log error
                      else
                        console.log result

                    Meteor.call 'aligo', '[홈리에종]\n 안녕하세요! 당신의 디자인을 소중하게 생각하는 파트너 홈리에종입니다 :) '+$('#ceoName').val()+'님의 디자이너 신청접수가 완료되었습니다. 홈리에종에서 등록하신 정보를 검토하고 심사가 완료되면 안내메일을 보내드립니다. http://home-liaison.com"', $('#mobile').val(), (error, result)->
                      if error
                        console.log error
                      else
                        console.log result

Template.A600_application.events

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

  #TODO 라디오 버튼 체크 부분분
  'click .radio-option' : (e, t) ->
    checked = $(e.currentTarget).hasClass('checked')
    name = $(e.currentTarget).find('input').attr('name')
    if !checked
      $('input[name="' + name + '"]').parent().removeClass 'checked'
      $('input[name="' + name + '"]').attr('checked', false)
      $(e.currentTarget).addClass 'checked'
      $(e.currentTarget).find('input').attr('checked', true)

    if $(e.currentTarget).find('input').val() isnt '프리랜서(사업자 없음)'
      t.businessType.set true
    else
      t.businessType.set false

  'change .selectMonth' : (e, t) ->
    Template.instance().month.set $('.selectMonth').val()

  'click #submitButton' : (e, t) ->

#    businessType = $('input:radio[name=businessType]:checked').val()
    businessType = $('.businessType .checked input').val()

    if businessType isnt '프리랜서(사업자 없음)' and $('#companyName').val() is ''
      sweetAlert "회원가입 실패", "회사명을 입력해주세요", "error"
      return
    if businessType isnt '프리랜서(사업자 없음)' and $('#businessLicenseNumber').val() is ''
      sweetAlert "회원가입 실패", "사업자 등록번호를 입력해 주세요", "error"
      return
    if businessType isnt '프리랜서(사업자 없음)' and t.businessLicenseFileName.get() is ''
      sweetAlert "회원가입 실패", "사업자 등록증을 등록해 주세요", "error"
      return

    $('#application-form').submit()

  'click #licenseFileButton, click #businessLicenseFileName' : (e, t) ->
    $('#businessLicenseFile').trigger('click')

  'click #bankbookImageButton, click #bankbookImageFileName' : (e, t) ->
    $('#bankbookImageUrl').trigger('click')

  'change #businessLicenseFile' : (e, t) ->
    file = $("#businessLicenseFile").get(0).files[0]
    instance =  Template.instance()

    fileUploader.send file, (err, downloadUrl) ->
      if err
        console.log "error", err
      else
        instance.businessLicenseFileUrl.set downloadUrl
        instance.businessLicenseFileName.set file.name
        $('#businessLicenseFileName').val(file.name)

  'change #bankbookImageUrl' : (e, t) ->
    file = $("#bankbookImageUrl").get(0).files[0]
    instance =  Template.instance()

    fileUploader.send file, (err, downloadUrl) ->
      if err
        console.log "error", err
      else
        instance.bankbookImageFileUrl.set downloadUrl
        instance.bankbookImageFileName.set file.name
        $('#bankbookImageFileName').val(file.name)

Template.A600_application.helpers

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



