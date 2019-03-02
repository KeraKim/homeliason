@OpenLink = (link) =>
  if link.startsWith '/'
    FlowRouter.go link
  else
    link = 'http://' + link unless link.match /^https?:/
    window.open link, if Meteor.isCordova then '_system' else '_blank'

@IsAndroid = ->
  navigator.userAgent.match(/android/i)

@IsIOS = ->
  navigator.userAgent.match(/(iphone)|(ipod)|(ipad)/i)

@OpenAndroidIntent = (link) ->
  window.plugins.webintent.startActivity
    action: window.plugins.webintent.ACTION_VIEW
    url: link
  ,
    -> console.log 'success:', arguments
  ,
    -> console.log 'fail:', arguments