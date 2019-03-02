require './A105_terms.tpl.jade'

Template.A105_terms.onCreated ->

  @state = new ReactiveVar '서비스 이용약관'

Template.A105_terms.onRendered ->

  @subscribe 'terms'

Template.A105_terms.events

  'click .tabs li' : (e, t) ->
    $(e.currentTarget).closest('.tabs').find('li').removeClass 'active'
    $(e.currentTarget).addClass 'active'
    type = $(e.currentTarget).find('span').text()
    Template.instance().state.set type

Template.A105_terms.helpers

  title : ->
    Template.instance().state.get()


  terms : ->
    type = Template.instance().state.get()
    terms = Terms.findOne( type : type )
    terms?.text