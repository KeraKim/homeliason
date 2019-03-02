@Reviews = new Mongo.Collection 'reviews'

reviewsSchema = new SimpleSchema

  userId :
    type : String
  designerId :
    type : String
  portfolioId :
    type : String
  productId :
    type : String
  score :
    type : Number
  content :
    type : String
  isActive:
    type: Boolean
  isVisible:
    type: Boolean
  createdAt:
    type: Date