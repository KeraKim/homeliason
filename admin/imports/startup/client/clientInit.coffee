# sAlert 초기화
Meteor.startup ->
  sAlert.config
    effect: 'slide'
    position: 'top-right'
    timeout: 1500
    html: false
    onRouteClose: true
    stack: true
    limit: 3
    offset: 0