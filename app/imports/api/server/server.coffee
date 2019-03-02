#
#Accounts.onCreateUser (options, user) ->
#  user.profile = options.profile or {}
#
#  user.profile = _.extend user.profile,
#    isApproved : false,
#    role : '사용자',
#    isActive: true
#
#  return user