@Notification = new Mongo.Collection 'notification'

notificationSchema = new SimpleSchema

  userId :
    type: String
  title :
    type : String
  text :
    type : String
  read :
    type : Boolean
  type :
    type : String
    allowedValues : ['products', 'holiday']
  createdAt:
    type: Date


