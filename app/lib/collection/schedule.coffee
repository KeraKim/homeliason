@Schedule = new Mongo.Collection 'schedule'

scheduleSchema = new SimpleSchema

#  userId :
#    type : String
  designerId :
    type : String
  portfolioId :
    type : String
  productId :
    type : String
  type :
    type : String
    allowedValues : ['reservation', 'holiday']
#  reserveDate :             # 서비스 예약 일
#    type : Date
#  workDurationInDay :       # 작업 소요 기간 (이름 추천)
#    type : Date
  effectiveDays :           # 유효날짜
    type : [Date]           # 모든 날짜를 넣ㄱ
#  holiday :                 # 작업이 불가능한 날짜 (이름 추천)
#    type : Date
  createdAt:
    type: Date

