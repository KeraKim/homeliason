@Faqs = new Mongo.Collection 'faqs'

faqsSchema = new SimpleSchema

  title:                    # FAQ 제목
    type: String
  content:                   # FAQ 내용
    type: String
  isActive:                 # 삭제 여부
    type: Boolean
  isVisible:                # 노출 여부
    type: Boolean
  createdAt:                 # 작성 일
    type: Date
  updatedAt:                # 수정 일
    type: Date