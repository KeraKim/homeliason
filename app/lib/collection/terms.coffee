@Terms = new Mongo.Collection 'terms'

termsSchema = new SimpleSchema

  type:                     # 타입
    type: String
    allowedValues : ['서비스 이용약관', '개인정보 취급방침']
  title:                    # 제목 (필요시 사용)
    type: String
  content:                  # 내용
    type: String
  createdAt:
    type: Date
  updateAt:
    type: Date

