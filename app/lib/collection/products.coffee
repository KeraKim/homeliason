@Products = new Mongo.Collection 'products'

productsSchema = new SimpleSchema

  userId :
    type : String
  designerId :
    type : String
  portfolioId :
    type : String
  productCode :
    type : String
  productName :
    type : String
  price :
    type : Number
  isActive :
    type: Boolean
  isVisible :
    type : Boolean
  workDurationInDay :                       # 작업 소요 기간 (이름 추천)
    type : Date
  possibleWorkPerDay :                      # 하루에 몇개 가능한가 (이름 추천)
    type : Number
  onOfflineType :                  # 온라인 / 오프라인 구분
    type : String
    allowedValues : ['online', 'offline']
  simpleInfo :                # 간략한 정보
    type : String
  productSummary :            # 상품 개요
    type : String
  detailInfo :                # 상세 정보
    type : String
  imageUrl :
    type : [String]
  isFurnitureStyling :        # 가구 스타일링 체크 여부
    type : Boolean
  isOfflineServiceInfo :      # 오프라인 서비스용 정보
    type : Boolean
  isFabricStyling :           # 패브릭 스타일링
    type : Boolean
  isUnlimited :               # 무제한 예약
    type : Boolean
  commission :                # 수수료
    type : Number
  createdAt:
    type: Date
  updateAt:
    type: Date


