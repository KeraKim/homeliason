require './editGuide.tpl.jade'

pageInit = ->
  $('.editor').summernote
    height: 300
#  $('.editor').froalaEditor
#    height: 300

Template.editGuide.onCreated ->


Template.editGuide.onRendered ->
  pageInit()

  @subscribe 'terms', =>
    Tracker.afterFlush ->
      guide = Terms.findOne(type : '안내 사항')
#      $('#guideEditor').froalaEditor('html.set', guide.text)
      $('#guideEditor').summernote 'code', guide.text

Template.editGuide.events
  'click #btnGuide': ->
    Meteor.call 'terms.update', '안내 사항', $('#guideEditor').val(), (error, result)->
      if error
        console.log error
      else
        console.log result
        swal "Success", "안내 사항이 변경되었습니다.", "success"

Template.editGuide.helpers
