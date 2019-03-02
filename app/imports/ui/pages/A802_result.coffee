require './A802_result.tpl.jade'

Template.A802_result.onCreated ->
  @message = new ReactiveDict()
  @message.set 'text', ''

Template.A802_result.onRendered ->
  switch FlowRouter.getParam('pageName')
    when  'application'
      @message.set 'text', '디자이너 신청이 완료되었습니다.'
    when  'sighup'
      @message.set 'text', '회원가입이 완료되었습니다.'
    when  'payment'
      @message.set 'text', '결제가 정상적으로 완료되었습니다.'

Template.A802_result.helpers
  message : ->
    Template.instance().message.get('text')