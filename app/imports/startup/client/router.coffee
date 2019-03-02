{ FlowRouter } = require 'meteor/kadira:flow-router'
{ BlazeLayout } = require 'meteor/kadira:blaze-layout'

BlazeLayout.setRoot 'body'

RootGroup = FlowRouter.group {}

require '/imports/ui/layouts/mainMenuLayout.coffee'

require '/imports/ui/pages/component/header.coffee'
require '/imports/ui/pages/component/footer.coffee'
require '/imports/ui/pages/popup/qna_popup.coffee'

require '/imports/ui/pages/A100_index.coffee'

RootGroup.route '/',
  name: 'index'
  action: (params, queryParams) ->
    window.location.replace("http://www.home-liaison.com/index")
#    FlowRouter.redirect '/index'

RootGroup.route '/index',
  name: 'index'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A100_index'
      qna_popup: 'qna_popup'

#################################
# Menus Group
#################################
MenusGroup = RootGroup.group
  prefix: '/menus'
  name: 'menus'

require '/imports/ui/pages/A101_intro.coffee'

MenusGroup.route '/intro',
  name: 'intro'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A101_intro'
      qna_popup: 'qna_popup'

require '/imports/ui/pages/A102_notices.coffee'

MenusGroup.route '/notices',
  name: 'notices'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A102_notices'
      qna_popup : 'qna_popup'

require '/imports/ui/pages/A103_faqs.coffee'

MenusGroup.route '/faqs',
  name: 'faqs'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A103_faqs'
      qna_popup : 'qna_popup'

require '/imports/ui/pages/A104_qna.coffee'

MenusGroup.route '/qna',
  name: 'qna'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A104_qna'
      qna_popup : 'qna_popup'

require '/imports/ui/pages/A105_terms.coffee'

MenusGroup.route '/terms',
  name: 'terms'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A105_terms'
      qna_popup : 'qna_popup'

#################################
# Contents Group
#################################
ContentsGroup = RootGroup.group
  prefix: '/contentManagement'
  name: 'contentManagement'

require '/imports/ui/pages/A300_portfolios.coffee'

ContentsGroup.route '/portfolios',
  name: 'portfolios'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A300_portfolios'
      qna_popup : 'qna_popup'

require '/imports/ui/pages/A301_portfolio.coffee'

ContentsGroup.route '/designers/:designerId/portfolios/:portfolioId',
  name: 'portfolio'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A301_portfolio'
      qna_popup : 'qna_popup'

require '/imports/ui/pages/A302_product.coffee'

ContentsGroup.route '/designers/:designerId/portfolios/:portfolioId/products/:productId',
  name: 'product'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A302_product'
      qna_popup : 'qna_popup'

require '/imports/ui/pages/A303_payment.coffee'

ContentsGroup.route '/designers/:designerId/portfolios/:portfolioId/products/:productId/payment',
  name: 'payment'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A303_payment'
      qna_popup : 'qna_popup'

require '/imports/ui/pages/A400_designers.coffee'

ContentsGroup.route '/designers',
  name: 'designers'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A400_designers'
      qna_popup : 'qna_popup'

require '/imports/ui/pages/A401_designer.coffee'

ContentsGroup.route '/designers/:designerId',
  name: 'designer'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A401_designer'
      qna_popup : 'qna_popup'

require '/imports/ui/pages/A1000_likes.coffee'

ContentsGroup.route '/likes',
  name: 'likes'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A1000_likes'
      qna_popup : 'qna_popup'

#################################
# Marketings Group
#################################
MarketingsGroup = RootGroup.group
  prefix: '/marketings'
  name: 'marketings'

require '/imports/ui/pages/A500_events.coffee'

MarketingsGroup.route '/events',
  name: 'events'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A500_events'
      qna_popup: 'qna_popup'

#################################
# User Group
#################################
UsersGroup = RootGroup.group
  prefix: '/userManagement'
  name: 'userManagement'

require '/imports/ui/pages/A600_application.coffee'

UsersGroup.route '/application',
  name: 'application'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A600_application'
      qna_popup: 'qna_popup'

require '/imports/ui/pages/A700_signup.coffee'

UsersGroup.route '/signup',
  name: 'signup'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A700_signup'
      qna_popup: 'qna_popup'

require '/imports/ui/pages/A800_login.coffee'

UsersGroup.route '/login',
  name: 'login'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A800_login'
      qna_popup: 'qna_popup'

require '/imports/ui/pages/A801_findPassword.coffee'

UsersGroup.route '/findPassword',
  name: 'findPassword'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A801_findPassword'
      qna_popup: 'qna_popup'

require '/imports/ui/pages/A802_result.coffee'

RootGroup.route '/result/:pageName',
  name: 'result'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A802_result'
      qna_popup: 'qna_popup'

require '/imports/ui/pages/A803_changePassword.coffee'

UsersGroup.route '/changePassword',
  name: 'changePassword'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A803_changePassword'
      qna_popup: 'qna_popup'

require '/imports/ui/pages/A804_resetPassword.coffee'

UsersGroup.route '/resetPassword/:token',
  name: 'resetPassword'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A804_resetPassword'
      qna_popup: 'qna_popup'

#################################
# Adjustments Group
#################################
AdjustmentsGroup = RootGroup.group
  prefix: '/adjustmentsManagement'
  name: 'adjustmentsManagement'

require '/imports/ui/pages/A900_order.coffee'

AdjustmentsGroup.route '/order',
  name: 'order'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A900_order'
      qna_popup: 'qna_popup'

#################################
# Monitoring Group
#################################
MonitoringGroup = RootGroup.group
  prefix: '/monitoring'
  name: 'monitoring'

require '/imports/ui/pages/A1100_qnas.coffee'

MonitoringGroup.route '/qnas',
  name: 'qnas'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A1100_qnas'
      qna_popup: 'qna_popup'

require '/imports/ui/pages/A1200_myProfile.coffee'

UsersGroup.route '/myProfile',
  name: 'myProfile'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A1200_myProfile'
      qna_popup: 'qna_popup'

require '/imports/ui/pages/A1300_dropOut.coffee'

UsersGroup.route '/dropOut',
  name: 'dropOut'
  action: (params, queryParams) ->
    BlazeLayout.render 'mainMenuLayout',
      main: 'A1300_dropOut'
      qna_popup: 'qna_popup'