require './routes.coffee'
require './connections.coffee'
require '/imports/api/methods.coffee'
require '/imports/api/client/helpers.coffee'
require '/imports/startup/client/clientInit.coffee'

Accounts.onLogout (user) ->
  FlowRouter.go 'login'