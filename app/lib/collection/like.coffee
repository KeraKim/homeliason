@Like = new Mongo.Collection 'like'

likeSchema = new SimpleSchema

  usersId :
    type : String
  designerId :
    type : String
  portfolioId :
    type : String
  isLike :
    type : Boolean
  createdAt:
    type: Date
  updatedAt:
    type: Date




