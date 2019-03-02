#require '/imports/api/client/kakao.min.js'
require '/imports/api/client/kakao.js'

#console.log 'Meteor.settings: ', Meteor.settings
#Kakao.init Meteor.settings.public.services.kakao
Kakao.init "49604f18272b88c2c98b903203203885"