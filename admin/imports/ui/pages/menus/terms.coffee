require './terms.tpl.jade'

pageInit = ->
#  $('.editor').froalaEditor
#    height: 300
  $('.editor').summernote
    height: 300

Template.terms.onCreated ->


Template.terms.onRendered ->
  pageInit()

  @subscribe 'terms', =>
    Tracker.afterFlush ->
      Terms.find().forEach (term)->
        switch term.type
          when '서비스 이용약관'
#            $('#termsEditor').froalaEditor('html.set', term.text)
            $('#termsEditor').summernote 'code', term.text
          when '개인정보 취급방침'
#            $('#privacyEditor').froalaEditor('html.set', term.text)
            $('#privacyEditor').summernote 'code', term.text
          when '탈퇴시 유의사항'
            #            $('#privacyEditor').froalaEditor('html.set', term.text)
            $('#dropOutEditor').summernote 'code', term.text


Template.terms.events
  'click .saveButton': ->
    Meteor.call 'terms.update', '서비스 이용약관', $('#termsEditor').val(), (error, result)->
      if error
        console.log error
      else
        console.log result

    Meteor.call 'terms.update', '개인정보 취급방침', $('#privacyEditor').val(), (error, result)->
      if error
        console.log error
      else
        console.log result

    Meteor.call 'terms.update', '탈퇴시 유의사항', $('#dropOutEditor').val(), (error, result)->
      if error
        console.log error
      else
        console.log result
        swal "Success", " 약관변경이 완료되었습니다.", "success"

#  'click #btnPrivacy': ->
#    Meteor.call 'terms.update', '개인정보 취급방침', $('#privacyEditor').val(), (error, result)->
#      if error
#        console.log error
#      else
#        console.log result
#        swal "Success", "개인정보 취급방침이 변경되었습니다.", "success"

Template.terms.helpers
