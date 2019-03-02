require './designers.tpl.jade'

{ saveAs } = require '/imports/api/client/FileSaver.min.js'
{ state } = require '/imports/ui/components/searchForm.coffee'
{ buildQuery } = require '/imports/ui/components/searchForm.coffee'

Template.designers.onCreated ->
  @subscribe 'designers'
  @designer = new ReactiveVar ''

Template.designers.onRendered ->

  searchIdTexts = []
  initial =
    id: 'profile.name'
    text: '이름'
  searchIdTexts.push initial
  searchIdTexts.push
    id: 'profile.designerEmail'
    text: '이메일'
  searchIdTexts.push
    id: 'profile.mobile'
    text: '휴대전화'
  searchIdTexts.push
    id: 'profile.career'
    text: '경력'
  searchIdTexts.push
    id: 'profile.sido'
    text: '지역'
  state.set 'searchIdTexts', searchIdTexts
  state.set 'currentSearchIdText', initial
  state.set 'startsAt', ''

clearAllCheckbox = ->
  $('input.visible-check').prop 'checked', false
  $('input.visible-check-all').prop 'checked', false

checkSelectedCheckbox = ->
  if 1 > $('tbody tr').find(":checkbox:checked").length
    swal "디자이너 미선택", "디자이너를 선택해 주세요", "error"
    false
  else
    true

Template.designers.events
  'change input[name=checkAll]': (e)->
    checked = $('input[name=checkAll]').is ':checked'
    $('input.visible-check').prop 'checked', checked

  'click #btnApprov': (e, t) ->
    unless checkSelectedCheckbox()
      return
    for element in $('tbody tr').find(":checkbox:checked")
      user = Blaze.getData(element)
      Meteor.call 'designers.approval', user._id
      if !user.profile.isExternalUser
#        Accounts.sendResetPasswordEmail user._id, user.emails[0].address

        Meteor.call 'aligo', '[홈리에종]\n 안녕하세요! 당신의 디자인을 소중하게 생각하는 파트너 홈리에종입니다 :) '+user.profile.ceoName+'님의 디자이너 승인이 완료되었습니다. 홈리에종에서 배포하는 디자이너 가이드를 참고하여 디자이너 등록, 포트폴리오 등록, 상품등록을 진행해보세요! http://home-liaison.com', user.profile.firstMobileNumber.concat(user.profile.meddleMobileNumber, user.profile.lastMobileNumber), (error, result)->
          if error
            console.log error
          else
            console.log result
      else
#        mailDateObject = {
#          templateName : '[홈리에종] 디자이너 승인이 완료되었습니다. 비밀번호를 설정해주세요.'
#          content1 : user.profile.ceoName,
#        }
#        Meteor.call 'mandrill', user.emails[0].address, user.profile.ceoName, '[홈리에종] 디자이너 승인이 완료되었습니다. 비밀번호를 설정해주세요.', mailDateObject, (error, result) ->
#          if error
#            console.log error
#          else
#            console.log result

        Accounts.forgotPassword
          email : user.emails[0].address
        , (err) ->
          if err
            if err.message is "User not found [403]"
              sweetAlert "이메일 찾기 실패", "가입되지 않은 이메일 입니다.", "error"
          else
            sweetAlert "메일 발송", "입력된 이메일 주소를 확인해주세요.", "success"

        Meteor.call 'aligo', '[홈리에종]\n 안녕하세요! 당신의 디자인을 소중하게 생각하는 파트너 홈리에종입니다 :) '+user.profile.ceoName+'님의 디자이너 승인이 완료되었습니다. 홈리에종에서 배포하는 디자이너 가이드를 참고하여 디자이너 등록, 포트폴리오 등록, 상품등록을 진행해보세요! http://home-liaison.com', user.profile.firstMobileNumber.concat(user.profile.meddleMobileNumber, user.profile.lastMobileNumber), (error, result)->
          if error
            console.log error
          else
            console.log result

        Meteor.call 'designer.update.externalUser', user._id, user.emails[0].address



  'click #btnRevocation ': (e, t) ->
    unless checkSelectedCheckbox()
      return
    for element in $('tbody tr').find(":checkbox:checked")
      user = Blaze.getData(element)
      Meteor.call 'designers.revocation', user._id

  'click #btnRemove': (e)->
    unless checkSelectedCheckbox()
      return
    swal
      title: "삭제"
      text: "디자이너를 탈퇴 시키시겠습니까?"
      type: "warning"
      showCancelButton: true
      cancelButtonText: '취소'
#      confirmButtonColor: "#DD6B55"
      confirmButtonText: "삭제"
      closeOnConfirm: false
      html: false
    , ->
      for element in $('tbody tr').find(":checkbox:checked")
        user = Blaze.getData(element)
        Meteor.call 'user.dropout', user._id,
          isActive: false
      clearAllCheckbox()
      swal "결과", "탈퇴 되었습니다.", "success"

  'click #btnExcel': (e)->
    query = buildQuery()
    rawData = []
    Meteor.users.find(query).map (designer) ->
      status = if designer.profile.isApproved is false then '승인 대기중' else '활동중'
      firstMobileNumber = designer.profile.firstMobileNumber
      meddleMobileNumber = designer.profile.meddleMobileNumber
      lastMobileNumber = designer.profile.lastMobileNumber
      foundedYear = designer.profile.foundedYear
      foundedMonth = designer.profile.foundedMonth
      foundedDay = designer.profile.foundedDay
      careerYear = designer.profile.careerYear
      careerMonth = designer.profile.careerMonth
      sido = designer.profile.sido
#      gugun = designer.profile.gugun
      gugun = ''
      eubmyeondong = designer.profile.eubmyeondong
      firstFaxNumber = designer.profile.firstFaxNumber
      meddleFaxNumber = designer.profile.meddleFaxNumber
      lastFaxNumber = designer.profile.lastFaxNumber
      firstPhoneNumber = designer.profile.firstPhoneNumber
      meddlePhoneNumber = designer.profile.meddlePhoneNumber
      lastPhoneNumber = designer.profile.lastPhoneNumber
      companyName = designer.profile.companyName
      if companyName is undefined
        companyName = ''

      businessLicenseNumber = designer.profile.businessLicenseNumber
      if businessLicenseNumber is undefined
        businessLicenseNumber = ''

      obj = {}
      obj['승인일'] = designer.profile.approvedAt
      obj['상태'] = status
      obj['신청일'] = designer.profile.reportedAt
      obj['이름'] = designer.profile.userName
      obj['로그인 이메일'] = designer.emails[0].address
      obj['디자이너 이메일'] = designer.profile.designerEmail
#      obj['휴대전화'] = firstMobileNumber.concat('-',meddleMobileNumber,'-',lastMobileNumber)
      obj['휴대전화'] = firstMobileNumber + ' - '+ meddleMobileNumber + ' -  '+ lastMobileNumber
      obj['구분'] = designer.profile.businessType
#      obj['경력'] = careerYear.concat('년',careerMonth,'개월')
      obj['경력'] = careerYear+'년 '+careerMonth+'개월'
      obj['지역'] = designer.profile.activeArea
      obj['회사 이름'] = companyName
      obj['사업자 번호'] = businessLicenseNumber
      obj['대표자 이름'] = designer.profile.ceoName
#      obj['개업일'] = foundedYear.concat('-',foundedMonth,'-',foundedDay)
      obj['개업일'] = foundedYear+' - '+foundedMonth + ' - ' +foundedDay
#      obj['주소'] = sido.concat(' ',gugun,' ',eubmyeondong)
      obj['주소'] = sido + ' ' + gugun + ' ' + eubmyeondong
#      obj['전화번호'] = firstPhoneNumber.concat('-',meddlePhoneNumber,'-',lastPhoneNumber)
      obj['전화번호'] = firstPhoneNumber + ' - ' + meddlePhoneNumber + ' - ' + lastPhoneNumber
#      obj['팩스'] = firstFaxNumber.concat('-',meddleFaxNumber,'-',lastFaxNumber)
      obj['팩스'] = firstFaxNumber + ' - ' + meddleFaxNumber + ' - ' + lastFaxNumber
      obj['은행명'] = designer.profile.bankName
      obj['예금주'] = designer.profile.accountName
      obj['계좌번호'] = designer.profile.accountNumber
      obj['포트폴리오 갯수'] = designer.profile.portfolioCount
      obj['상품 갯수'] = designer.profile.productCount

      rawData.push obj
    csv = json2csv rawData, true, true
    blob = new Blob [csv], {type: "text/plain;charset=utf-8;",}
    #    console.log 'blob', csv
    saveAs blob, "designer.csv"

  'click #userName' : (e, t) ->
    designer = Blaze.getData(e.currentTarget)
    Template.instance().designer.set designer
    $('.designerModal').modal 'show'

Template.designers.helpers
  designers: ->
    query = buildQuery()
    query['profile.isDesigner'] = true
    page = FlowRouter.getQueryParam 'page' or 1
    limit = 10
    options =
      limit: limit
      skip: (page - 1) * limit
      sort:
        'profile.isApproved': 1,
        createdAt: -1
    Meteor.users.find query, options

  pageTotalCount: ->
    query = {}
    Meteor.users.find(query).count()

  status: (user)->
    if user.profile.isApproved then '활동중' else '승인대기'

  dateFormat: (date)->
    if date is '-'
      '-'
    else
      moment(date).format('YYYY-MM-DD')

  designer : ->
    Template.instance().designer.get()

  businessLicenseNumberFormat: (licenseNumber) ->
    if licenseNumber
      firstNumber = licenseNumber.substr(0,3)
      meddleNumber = licenseNumber.substr(3,2)
      lastNumber = licenseNumber.substr(5,5)
      firstNumber.concat('-',meddleNumber,'-',lastNumber)
    else
      ''

