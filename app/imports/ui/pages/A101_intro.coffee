require './A101_intro.tpl.jade'

Template.A101_intro.onRendered ->

  @autorun =>
    if @subscriptionsReady()
      Tracker.afterFlush =>
        $('.parallax1').parallax imageSrc: '/img/a-101-pic-1@2x.jpg'
        $('.parallax2').parallax imageSrc: '/img/a-101-pic-3@2x.png'

  Meteor.setTimeout ->
    $('.parallax1').addClass 'fadeIn'
  , 1000

Template.A101_intro.onDestroyed ->
  $('.parallax-mirror').remove()