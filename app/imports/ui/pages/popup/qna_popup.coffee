require './qna_popup.tpl.jade'

Template.qna_popup.onCreated ->

Template.qna_popup.onRendered ->

  @autorun =>
    $('.qna-form').validate
      rules:
        title :
          required: true
        content:
          required: true
        email:
          required: true
          email: true
      messages:
        title :
          required: '제목을 입력해 주세요'
        content:
          required: '본문 내용을 입력해 주세요'
        email:
          required: '이메일을 입력해주세요'
          email: '메일 형식에 맞지않습니다.'

      errorPlacement: (error, element) ->
        $(element).closest('div').find('.error-text').html error

      submitHandler: (form, validator) ->

        qna =
          title : $('.qna-title').val()
          content : $('.qna-content').val()
          email : $('.qna-email').val()
          type : '사이트 문의'

        Meteor.call 'qnas.insert', qna, (error, result)->
          if error
            console.log error
          else
            mailDateObject = {
              templateName : '[홈리에종] 문의사항이 접수되었습니다.'
            }
            $('.qna-title').val('')
            $('.qna-content').val('')
            sweetAlert '문의작성 완료', '문의내용이 저장되었습니다.', 'success'
            Meteor.call 'mandrill', qna.email, '홈리에종 사용자님', '[홈리에종] 1:1 문의가 접수되었습니다. 빠른 시간 내에 답변 드리겠습니다.', mailDateObject, (error, result) ->
              if error
                console.log error
              else
                console.log result

Template.qna_popup.events

  'click .submit-btn' : (e, t) ->
    $('.qna-form').submit()