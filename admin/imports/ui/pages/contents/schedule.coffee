require './schedule.tpl.jade'

Template.schedule.onCreated ->
  @designerId = new ReactiveVar ''
#  @subscribe 'designer.schedule', Meteor.userId()
#  @clickTest = new ReactiveVar []

Template.schedule.onRendered ->
  @autorun =>
    unless Meteor.user()
      return
    if Meteor.user().profile.isManager
      @designerId.set Meteor.user().profile.designerId
      @subscribe 'designer.schedule', @designerId.get()
    else
      @designerId.set Meteor.userId()
      @subscribe 'designer.schedule', @designerId.get()

  $('#holidayDrager').draggable
    revert: true
    revertDuration: 0

  instance = Template.instance()

  $('#fullcalendar').fullCalendar(
    droppable: true
    height: 'auto'
    drop: (date) ->
      schedule =
        effectiveDays : [moment(moment(date.format()).format('YYYY-MM-DD')).toDate()]
        designerId : instance.designerId.get()

      console.log schedule.effectiveDays

      Meteor.call 'schedules.add.holiday', schedule, (error, result) ->
        if error
          console.log error
        else
          console.log result

    eventClick: (event) ->
      if event.title is '휴일'
        schedule =
          holiday : moment(moment(event.start._i).format('YYYY-MM-DD')).toDate()
          designerId : instance.designerId.get()
        console.log 'delete holiday : ', schedule.holiday
        Meteor.call 'schedules.remove.holiday', schedule, (error, result) ->
          if error
            console.log error
          else
            console.log result
        $('#fullcalendar').fullCalendar('removeEvents', event._id)

    eventRender: (event, element) ->
#      if event.portfolioTitle and event.productTitle
      if event.productTitle
#        element.find('.fc-title').append '<br/>' + event.portfolioTitle
        element.find('.fc-title').append '<br/>' + event.productTitle
        element.css('background-color','#003366')
  )

  @autorun =>

    eventsArray = []
    $('#fullcalendar').fullCalendar('removeEventSources')
    schedules = Sales.find(designerId : @designerId.get())
    unless  schedules
      return

    schedules.forEach (schedule) ->
      if schedule.type is 'reservation' and schedule.status is '결제'
        product = Products.findOne(_id : schedule.productId)
        unless  product
          return

        portfolio = Portfolios.findOne(_id : schedule.portfolioId)
        unless  portfolio
          return

        calendar =
#          title : '예약접수'
          title : portfolio.title
          start : moment(schedule.effectiveDays[0]).format('YYYY-MM-DD')
          end : moment(moment(schedule.effectiveDays[schedule.effectiveDays.length-1]).format('YYYY-MM-DD')).add(1, 'days')
#          portfolioTitle : portfolio.title
          productTitle :  product.title
          backgroundColor : 'orange'

        eventsArray.push calendar

      else if schedule.type is 'holiday'
        calendar =
          title : '휴일'
          start : moment(schedule.effectiveDays[0]).format('YYYY-MM-DD')
          end : moment(schedule.effectiveDays[0]).format('YYYY-MM-DD')
          backgroundColor : 'orange'

        eventsArray.push calendar



    $('#fullcalendar').fullCalendar('addEventSource', eventsArray)


Template.schedule.events
