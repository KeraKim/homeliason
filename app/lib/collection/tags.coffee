@Tags = new Mongo.Collection 'tags'

tagsSchema = new SimpleSchema

#  designerId :
#    type : String
#  portfolioId :
#    type : String
#  product :
#    type : String
  tagName :
    type : String
  clickCount :          #클릭수
    type : Number
  registerCount :       #등록수
    type : Number
  isRecommend :
    type : Boolean      #추천 태그
  isActive:
    type: Boolean
  isVisible:
    type: Boolean
  createdAt:
    type: Date

  # 디자이너, 상품 아이디도 참조시킬것,