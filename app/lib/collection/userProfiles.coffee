
#usersSchema = new SimpleSchema
#  _id:
#    type: String
#  userEmail :
#    type : String
#  userName :
#    type : String
#  imageUrl :
#    type : String
#  isAdmin:
#    type: Boolean
#  isDesigner:
#    type: Boolean
#  isActive:
#    type: Boolean
#  createdAt:
#    type: Date
#  updateAt:
#    type: Date
# likes :
#   type : [String]


###################### 디자이너 신청 부분 ########################
#
#  businessType :                #디자이너 타입
#    type : String
#    allowedValues ['법인 사업자', '개인 사업자', '개인']
#  companyName :                 #회사명
#    type : String
#  businessLicenseNumber :       #사업자등록번호
#    tpye : Number
#  ceoName :                     #대표자 명
#    type : String
#  foundedAt :                   #회사 설립 일
#    type : Date
#  sido :                        #시도
#    type : String
#  gugun :                       #구군
#    type : String
#  eubmyeondong :                #읍면동
#    type : String
#  firstPhoneNumber :                         # 전화번호
#    type : String
#  meddlePhoneNumber :                         # 전화번호
#    type : String
#  lastPhoneNumber :                         # 전화번호
#    type : String
#  firstMobileNumber :                       # 핸드폰 번호
#    type : String
#  meddleMobileNumber :                       # 핸드폰 번호
#    type : String
#  LastMobileNumber :                       # 핸드폰 번호
#    type : String
#  fax :                        # 팩스 번호
#    type : String
#  designerEmail :               # 디자이너 이메일
#    type : String
#  career :                      # 경력
#    type : String
#  businessLicenseUrl :           # 사업자 등록증 URL
#    type : String
#  isApproved :                   # 디자이너 승인 여부
#    type : Boolean
#  approvedAt :                   # 디자이너 승인 날짜 (유저정보 중복)
#    type : Date
#  reportedAt :                  # 디자이너 신청 날짜
#    type : Date


###################### 디자이너 승인 후 채우는 정보들 ########################
#  designerName :
#    type : String
#  designerRectangleImageUrl :
#    type : String
#  designerSquareImageUrl :
#    type : String
#  simpleInfo :               # 간략한 정보
#    type : String
#  detailInfo :                # 상세 정보
#    type : String
#  activeArea :                # 활동 영역
#    type : String
#  specialty :                 # 전문 영역
#    type : String
#  homePageUrl :
#    type : String
#  blogUrl :
#    type : String
#  instagramUrl :
#    type : String
#  twitterUrl :
#    type : String
#  facebookUrl :
#    type : String
#  averageScore :              # 평점
#    type : Number
#  bankName :
#    type : String
#  accountHolder :
#    type : String
#  accountNumber :
#    type : Number
#  portfolioCount :
#    type : Number
#  productCount :
#    type : Number





