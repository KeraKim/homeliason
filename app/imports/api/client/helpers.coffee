Template.registerHelper 'getPageTitle', ->
  if Meteor.user() then '수정' else '등록'

Template.registerHelper 'selectedIfEquals', (value, other) ->
  'selected' if value is other

Template.registerHelper 'checkedIf', (value) ->
  'checked' if value

Template.registerHelper 'checkedIfEquals', (value, other) ->
  'checked' if value is other

Template.registerHelper 'disabledIf', (value) ->
  'disabled' if value

