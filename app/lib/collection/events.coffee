@Events = new Mongo.Collection 'events'

eventsSchema = new SimpleSchema

  portfolioId :
    type : String
  productId :
    type : String
  title :
    type : String
  content :
    type : String
  imageUrl :
    type : String
  startsAt:              # 노출 시작 일시
    type: Date
  endsAt:                # 노출 종료 일시
    type: Date
  isEndless:             # 노출 종료 일시 없음
    type: Boolean
  isActive:
    type: Boolean
  isVisible:
    type: Boolean
  isPopup:
    type : Boolean
  createdAt:
    type: Date
  updatedAt:
    type: Date