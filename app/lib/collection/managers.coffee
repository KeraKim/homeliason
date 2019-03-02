@Managers = new Mongo.Collection 'managers'

managersSchema = new SimpleSchema

  designerId :
    type : String
  managerName :
    type : String
  managerEmail :
    type : String
  managerPhone :
    type : String
  isManager :
    type : Boolean
