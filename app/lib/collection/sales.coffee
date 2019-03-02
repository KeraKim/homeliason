@Sales = new Mongo.Collection 'sales'

salesSchema = new SimpleSchema

  userId :
    type : String
  designerId :
    type : String
  portfolioId :
    type : String
  productId :
    type : String
  imp_uid :                     # 아임포트 거래 고유 번호
    type : String
  merchant_uid :                # 가맹점에서 생성/관리하는 고유 주문번호
    type : String
  pay_method :                  # 결제 수단
    type : String
  price :
    type : Number
  status  :
    type : String
    allowedValues : ['결제', '사용자 취소', '관리자 환불']
#  detail :
#    type : []                 # 결제 정보들
  createdAt:
    type: Date
  completeAt:                  # 서비스 종료 날짜
    type: Date
  type :
    type : String
    allowedValues : ['reservation', 'holiday']
  effectiveDays :           # 유효날짜 (작업 하는날)
    type : [Date]
  commission :              # 수수료율
    type : Number

