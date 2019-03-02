#if Meteor.isClient
#  Tracker.autorun ->
#    console.log 'connection: ', Meteor.status().status
#    if Meteor.status().status is 'waiting'
#      console.log 'connection waiting................'
#      console.log Meteor.status()
#    if Meteor.status().retryCount > 3
#      alert '서버와의 연결이 끊어졌습니다. 나중에 다시 시도해 주세요.'
#      Meteor.disconnect()

#  Push.addListener 'token', (token)->
#    alert 'Token: ' + JSON.stringify(token)

#BrowserPolicy.content.allowOriginForAll("http://d-m.yapcompany.net")
