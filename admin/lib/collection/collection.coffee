@Portfolios = new Mongo.Collection 'portfolios'
@Notices = new Mongo.Collection 'notices'
@Faqs = new Mongo.Collection 'faqs'
@Terms = new Mongo.Collection 'terms'
@Products = new Mongo.Collection 'products'
@Qnas = new Mongo.Collection 'qnas'
@Events = new Mongo.Collection 'events'
@Sales = new Mongo.Collection 'sales'
@Tags = new Mongo.Collection 'tags'
@Schedule = new Mongo.Collection 'schedule'
@Reviews = new Mongo.Collection 'reviews'
@Notification = new Mongo.Collection 'notification'
@Managers = new Mongo.Collection 'managers'
@Adjustment = new Mongo.Collection 'adjustment'

Portfolios.helpers
  allTagsInArray: ->
    portfolios = Portfolios.find
      designerId: this.designerId
      isActive:
        $ne: false
    tagSet = new Set()
    portfolios.map (portfolio)->
      _.each portfolio.tags, (tag)->
        tagSet.add tag
    Array.from tagSet

