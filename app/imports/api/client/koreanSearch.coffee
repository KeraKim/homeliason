
runSearch = (inputStr)->
#  inputStr = prompt("초성 할 단어 입력", "화ㄱ")
  result = ""

  #입력된 문자열 길이만큼 반복 - [1]반복문
  k = 0
  while k < inputStr.length
    inputStr2 = inputStr.substring(k, k + 1) #입력한 단어 글자 단위로 나눠 담기
    inputCho = searchCho(inputStr2.charCodeAt(0)) #입력한 단어 초성 나누기
    forLength = 0
    checkArr = result.split(",") # 조회된결과를 배열로 나눔
    arrStr = ""

    #최초 조회시...
    if result is "" and k is 0
      forLength = font_test.length

    #두번째 조회 부터...
    else
      forLength = checkArr.length
      result = ""

    # 비교대상 배열의 길이만큼 반복 - [2]반복문
    i = 0
    while i < forLength

      #최초 조회시...
      if k is 0
        arrStr = font_test[i]

      #두번째 조회 부터...
      else
        arrStr = checkArr[i]

      #배열 값의 길이만큼 반복 - [3]반복문
      #단, j는 [1]반복문의 현재값으로 초기화
      j = k
      while j < arrStr.length
        #이전 검색된 문자
        beforeStr = arrStr.charCodeAt(j)
        beforeCho = searchCho(arrStr.charCodeAt(j))
        beforeInput = inputStr2
        if k > 0
          beforeStr = arrStr.charCodeAt(j - 1)
          beforeCho = searchCho(arrStr.charCodeAt(j - 1))
          beforeInput = inputStr.substring(k - 1, k)

        #한글이면
        if escape(inputStr2.charCodeAt(0)).length > 4 and result.indexOf(arrStr) < 0
          Cho = searchCho(arrStr.charCodeAt(j)) #조회 대상 배열의 값 초성 나누기

          #초성만 입력한 경우이면..
          if inputCho >= 0
            result += arrStr + ","  if font_cho[beforeCho] is beforeInput or beforeStr is beforeInput.charCodeAt(0)  if arrStr.charCodeAt(j) is inputStr2.charCodeAt(0)

          #초성인 경우...
          else
            result += arrStr + ","  if font_cho[beforeCho] is beforeInput or beforeStr is beforeInput.charCodeAt(0)  if font_cho[Cho] is inputStr2

        #영어면
        else
          #대문자로 변환뒤 비교
          result += arrStr + ","  if result.indexOf(arrStr) < 0  if inputStr2.toUpperCase().charCodeAt(0) is arrStr.toUpperCase().charCodeAt(j)
        j++
      i++
    k++

  result = "검색된 단어가 없습니다."  if result is ""
  alert "검색결과  : " + result

# 초성 나누기 return : 초성 배열 index
searchCho = (str) ->
  CompleteCode = str
  UniValue = CompleteCode - 0xAC00
  Jong = UniValue % 28
  Jung = ((UniValue - Jong) / 28) % 21
  Cho = parseInt(((UniValue - Jong) / 28) / 21)
  Cho

font_cho = Array("ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ")
font_jung = Array("ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ")
font_jong = Array("", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ")
font_test = Array("오징어", "땅콩", "드래곤볼", "드라군", "화곡", "질럿", "apple", "김삐짐", "정매너", "김김김", "윤삐짐", "Big", "Application", "개발자", "김호수", "김호구", "김백수", "윤백수", "백수왕", "매국노", "나그네", "우왕")
runSearch()