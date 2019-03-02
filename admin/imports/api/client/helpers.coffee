Template.registerHelper 'selectedIfEquals', (value, other) ->
  'selected' if value is other

Template.registerHelper 'checkedIf', (value) ->
  'checked' if value

Template.registerHelper 'checkedIfEquals', (value, other) ->
  'checked' if value is other

Template.registerHelper 'disabledIf', (value) ->
  'disabled' if value

#Meteor.startup ->
#  if Meteor.isClient
Template.registerHelper 'makeDate', (utc) ->
#  moment(utc).format 'YYYY-MM-DD'
  makeDate(utc)

Template.registerHelper 'makeTime', (utc) ->
  moment(utc).format 'HH:mm:ss'

#Template.registerHelper 'makeDateTime', (utc) ->
#  moment(utc).format 'YYYY-MM-DD HH:mm:ss'

Template.registerHelper 'makeDatetime', (utc) ->
#  console.log 'result', moment(utc).format 'YYYY-MM-DD HH:mm'
  moment(utc).format 'YYYY-MM-DD HH:mm'

Template.registerHelper 'priceComma', (num) ->
#  moment(utc).format 'YYYY-MM-DD'
  priceComma(num)

@priceComma = (num)->
  num = Math.round(num)
  len = undefined
  point = undefined
  str = undefined
  num = num + ''
  point = num.length % 3
  len = num.length
  str = num.substring(0, point)
  while point < len
    if str != ''
      str += ','
    str += num.substring(point, point + 3)
    point += 3
  str

@makeDate = (utc)->
  unless utc
    moment().format 'YYYY-MM-DD'
  moment(utc).format 'YYYY-MM-DD'

@makeDatetime = (utc)->
  unless utc
    moment().format 'YYYY-MM-DD HH:mm'
  moment(utc).format 'YYYY-MM-DD HH:mm'


@afterAWeek = ->
  moment().add(7, 'days')

Template.registerHelper 'formatAgo', (date)->
  moment.locale('kr')
  moment(date).fromNow()

Template.registerHelper 'formatDateDots', (date)->
  moment(date).format('YYYY.MM.DD')