require './A500_events.tpl.jade'

Template.A500_events.onCreated ->

  @event = new ReactiveVar ''
  @subscribe 'events'

Template.A500_events.events

  'click .eventItem' : (e, t) ->
    event = Blaze.getData(e.target)
    t.event.set event
    $('.appendDiv').html event.content
    modal = $(e.currentTarget).closest('section').find('.foundry_modal')
    modal.toggleClass 'reveal-modal'
    $('.modal-screen').toggleClass 'reveal-modal'

  $(document).on 'wheel mousewheel scroll', '.foundry_modal, .modal-screen', (evt) ->
    $(this).get(0).scrollTop += evt.originalEvent.deltaY
    false

Template.A500_events.helpers

  events : ->
    Events.find
      isActive : true
      isVisible : true

  event : ->
    Template.instance().event.get()

