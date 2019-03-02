require './router.coffee'
require './connections.coffee'
require './kakao.coffee'
require './cordova.coffee'

Accounts.onLogout (user) ->
  FlowRouter.go 'index'
