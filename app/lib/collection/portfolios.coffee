@Portfolios = new Mongo.Collection 'portfolios'

portfoliosSchema = new SimpleSchema

  designerId :
    type : String
  portfolioCode :
    type : String
  title :
    type : String
  sido :
    type : String
  gugun :
    type : String
  isActive :
    type: Boolean
  isVisible :
    type : Boolean
  progressedByHomeLiaison :       # 홈리에종을 통해 진행된 프로젝트
    type : Boolean
  workedYear :                    # 포트폴리오를 작업했던 날짜
    type : Number
  workedMonth :                    # 포트폴리오를 작업했던 날짜
    type : Number
  workedDay :                    # 포트폴리오를 작업했던 날짜
    type : Number
  simpleInfo :                  # 간략한 정보
    type : String
  detailInfo :                  # 상세 정보
    type : String
  tags :
    type : [String]
  imageUrl :
    type : [String]
  likeUserIds :
    type : [String]
  viewCount :                   #조회 순
    type : Number
#  reviewScore :
#    type : Number               #리뷰 점수 합
  createdAt:
    type: Date
  updateAt:
    type: Date