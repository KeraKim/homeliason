@Qnas = new Mongo.Collection 'qnas'

qnasSchema = new SimpleSchema

  userId :
    type: String
  email :                      # 답변 받을 이메일 주소
    type : String
  designerId :
    type : String
  portfolioId :
    type : String
  productId :
    type : String
  type :
    type : String
    allowedValues : ['리뷰 이의제기', '이벤트 신청', '사이트 문의', '디자이너 문의']
  title :
    type : String
  content :
    type: String
  answer :
    type : String
  isAnswered :
    type : Boolean
  answeredAt :
    type : Date
  createdAt:
    type: Date
  reviewWriter :                # 디자이너가 관리자에게 리뷰 이의제기할때 필요
    type : String

  #사용자가 비회원인지 일반회원인지 나누기