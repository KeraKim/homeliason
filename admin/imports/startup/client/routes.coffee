{ FlowRouter } = require 'meteor/kadira:flow-router'
{ BlazeLayout } = require 'meteor/kadira:blaze-layout'

require '/imports/ui/layouts/mainLayout.coffee'
require '/imports/ui/layouts/blankLayout.coffee'
require '/imports/ui/components/pageHeading.coffee'
require '/imports/ui/components/pagination.coffee'


BlazeLayout.setRoot 'body'

signInCheck = (context, redirect) ->
  unless Meteor.loggingIn() or Meteor.userId()
    FlowRouter.go 'login'

FlowRouter.triggers.enter [signInCheck],
  except: [
#    'login'
  ]

#################################
# Root Group
#################################
RootGroup = FlowRouter.group {}
RootGroup.route '/',
  name: 'index'
  action: ->
#    BlazeLayout.render 'mainLayout', main: 'jobs'
    console.log 'index : ', FlowRouter.getParam 'userId'
#    FlowRouter.go 'login'
    window.location.replace("http://www.home-liaison.com:3000/login")

require '/imports/ui/pages/login.coffee'
RootGroup.route '/login',
  name: 'login'
  action: ->
    BlazeLayout.render 'blankLayout', main: 'login'

#################################
# Menus Group
#################################
MenusGroup = RootGroup.group
  prefix: '/menus'
  name: 'menus'

require '/imports/ui/pages/menus/news.coffee'
MenusGroup.route '/news',
  name: 'news'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'news'

require '/imports/ui/pages/menus/userGuide.coffee'
MenusGroup.route '/userGuide',
  name: 'userGuide'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'userGuide'

require '/imports/ui/pages/menus/notices.coffee'
MenusGroup.route '/notices',
  name: 'notices'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'notices'

require '/imports/ui/pages/menus/editNotice.coffee'
MenusGroup.route '/notices/add',
  name: 'addNotice'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'editNotice'

MenusGroup.route '/notices/:id',
  name: 'editNotice'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'editNotice'

require '/imports/ui/pages/menus/faqs.coffee'
MenusGroup.route '/faqs',
  name: 'faqs'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'faqs'

require '/imports/ui/pages/menus/editFaq.coffee'
MenusGroup.route '/faqs/add',
  name: 'addFaq'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'editFaq'

MenusGroup.route '/faqs/:id',
  name: 'editFaq'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'editFaq'

require '/imports/ui/pages/menus/terms.coffee'
MenusGroup.route '/terms',
  name: 'terms'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'terms'

require '/imports/ui/pages/menus/editGuide.coffee'
MenusGroup.route '/editGuide',
  name: 'editGuide'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'editGuide'

require '/imports/ui/pages/menus/userGuide.coffee'
MenusGroup.route '/userGuide',
  name: 'userGuide'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'userGuide'

#################################
# Profile Group
#################################
ProfileGroup = RootGroup.group
  prefix: '/profileManagement'
  name: 'profileManagement'

require '/imports/ui/pages/user/editDesignerProfile.coffee'
ProfileGroup.route '/editDesignerProfile',
  name: 'editDesignerProfile'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'editDesignerProfile'

require '/imports/ui/pages/user/editCompanyProfile.coffee'
ProfileGroup.route '/editCompanyProfile',
  name: 'editCompanyProfile'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'editCompanyProfile'

require '/imports/ui/pages/user/managers.coffee'
ProfileGroup.route '/managers',
  name: 'managers'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'managers'

require '/imports/ui/pages/user/editManager.coffee'
ProfileGroup.route '/managers/add',
  name: 'addManager'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'editManager'

ProfileGroup.route '/managers/:id',
  name: 'editManager'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'editManager'

require '/imports/ui/pages/user/editSns.coffee'
ProfileGroup.route '/editSns',
  name: 'editSns'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'editSns'

require '/imports/ui/pages/user/editAccount.coffee'
ProfileGroup.route '/editAccount',
  name: 'editAccount'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'editAccount'

#################################
# User Group
#################################
UsersGroup = RootGroup.group
  prefix: '/userManagement'
  name: 'userManagement'

require '/imports/ui/pages/user/designers.coffee'
UsersGroup.route '/designers',
  name: 'designers'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'designers'

require '/imports/ui/pages/user/users.coffee'
UsersGroup.route '/users',
  name: 'users'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'users'

#################################
# Contents Group
#################################
ContentsGroup = RootGroup.group
  prefix: '/contentManagement'
  name: 'contentManagement'

require '/imports/ui/pages/contents/portfolios.coffee'
ContentsGroup.route '/portfolios',
  name: 'portfolios'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'portfolios'

require '/imports/ui/pages/contents/editPortfolio.coffee'
ContentsGroup.route '/portfolios/add',
  name: 'addPortfolio'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'editPortfolio'

ContentsGroup.route '/portfolios/:id',
  name: 'editPortfolio'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'editPortfolio'

require '/imports/ui/pages/contents/products.coffee'
ContentsGroup.route '/products',
  name: 'products'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'products'

require '/imports/ui/pages/contents/editProduct.coffee'
ContentsGroup.route '/products/add',
  name: 'addProduct'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'editProduct'

ContentsGroup.route '/products/:id',
  name: 'editProduct'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'editProduct'

require '/imports/ui/pages/contents/schedule.coffee'
ContentsGroup.route '/schedule',
  name: 'schedule'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'schedule'

require '/imports/ui/pages/contents/editCommission.coffee'
ContentsGroup.route '/products/:productId/commission',
  name: 'editCommission'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'editCommission'

#################################
# Adjustments Group
#################################
AdjustmentsGroup = RootGroup.group
  prefix: '/adjustmentsManagement'
  name: 'adjustmentsManagement'

require '/imports/ui/pages/adjustments/sales.coffee'
AdjustmentsGroup.route '/sales',
  name: 'sales'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'sales'

require '/imports/ui/pages/adjustments/adjustments.coffee'
AdjustmentsGroup.route '/adjustments',
  name: 'adjustments'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'adjustments'

require '/imports/ui/pages/adjustments/designerAdjustments.coffee'
AdjustmentsGroup.route '/designerAdjustments',
  name: 'designerAdjustments'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'designerAdjustments'

#################################
# Monitoring Group
#################################
MonitoringGroup = RootGroup.group
  prefix: '/monitoring'
  name: 'monitoring'

require '/imports/ui/pages/monitoring/qnas.coffee'
MonitoringGroup.route '/qnas',
  name: 'qnas'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'qnas'

require '/imports/ui/pages/monitoring/adminDesignerQnas.coffee'
MonitoringGroup.route '/adminDesignerQnas',
  name: 'adminDesignerQnas'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'adminDesignerQnas'

require '/imports/ui/pages/monitoring/designerQnas.coffee'
MonitoringGroup.route '/designerQnas',
  name: 'designerQnas'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'designerQnas'

require '/imports/ui/pages/monitoring/complainReview.coffee'
MonitoringGroup.route '/complainReview/add',
  name: 'complainReview'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'complainReview'

require '/imports/ui/pages/monitoring/reviews.coffee'
MonitoringGroup.route '/reviews',
  name: 'reviews'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'reviews'

#################################
# Marketings Group
#################################
MarketingsGroup = RootGroup.group
  prefix: '/marketings'
  name: 'marketings'

require '/imports/ui/pages/marketings/events.coffee'
MarketingsGroup.route '/events',
  name: 'events'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'events'

require '/imports/ui/pages/marketings/editEvents.coffee'
MarketingsGroup.route '/events/add',
  name: 'addEvents'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'editEvents'

MarketingsGroup.route '/events/:id',
  name: 'editEvents'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'editEvents'

require '/imports/ui/pages/marketings/tags.coffee'
MarketingsGroup.route '/tags',
  name: 'tags'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'tags'

require '/imports/ui/pages/marketings/applyEvent.coffee'
MarketingsGroup.route '/applyEvent/add',
  name: 'applyEvent'
  action: ->
    BlazeLayout.render 'mainLayout', main: 'applyEvent'
