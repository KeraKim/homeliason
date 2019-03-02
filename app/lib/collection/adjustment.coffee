@Adjustment = new Mongo.Collection 'adjustment'

adjustmentSchema = new SimpleSchema
  #정산
  designerId :
    type : String
#  sales :
#    type : []                     #판매된 내용들
  createdAt:
    type: Date
  completedAt :                   #정산이 이루어진 날짜
    type : Date
  scheduledAt :                   #실제 정산이 이루어져야하는 날짜
    type : Date
  termStartsAt :                  #정산 주기 시작일
    type : Date
  termEndsAt :                    #정산 주기 종료
    type : Date
  isComplete :
    type : Boolean
  bankName :
    type : String
  accountNumber :
    type : Number
  accountName :
    type : String
