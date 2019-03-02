@Notices = new Mongo.Collection 'notices'

NoticeSchema = new SimpleSchema
#  userId:
#    type: String
  title:                  # 공지사항 제목
    type: String
  content:                # 공지사항 내용
    type: String
  startsAt:              # 공지사항 노출 시작 일시 (optional)
    type: Date
  endsAt:                # 공지사항 노출 종료 일시 (optional)
    type: Date
  isEndless:             # 공지사항 노출 종료 일시 없음
    type: Boolean
  isActive:               # 삭제 여부
    type: Boolean
  isVisible:                # 노출 여부
    type: Boolean
  createdAt:              # 생성 일시
    type: Date
  updatedAt:              # 업데이트 일시
    type: Date
