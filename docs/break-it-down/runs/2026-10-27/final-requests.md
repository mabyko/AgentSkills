# 별도 세션에 제공한 요청

생성 세션에는 아래 요청과 해시를 기록한 스킬 사본만 제공했다. 판정 기준과 이전 출력은 제공하지 않았다.

## C2

$break-it-down 글: 아래 가상 복원 정책을 처음 이용하는 한국어 사용자에게 설명해줘. 언제 복원할 수 있는지 판단할 수 있게 해줘.

A normal restore requires both a snapshot less than 14 calendar days old and approval from the workspace owner. Downloading a snapshot saves a separate copy; it does not restore the workspace. If the team confirms that the service caused data corruption, the team restores the latest intact snapshot even when it is 14 calendar days old or older. Owner approval is required for both normal and corruption-related restores. The team usually replies within two business days, but this response time is not guaranteed.

## C5

$break-it-down 아래 가상 작업 기록을 보고 담당자가 현재 상태와 다음 확인을 판단할 수 있게 한국어 글로 설명해줘.

기록 순서: 11월 12일에 운영팀이 검색 노출 효과를 최종 판정할 예정이다. 문서 담당자는 위키 항목을 완료 표시했다. 수집 담당자는 검색어를 46개에서 58개로 늘렸고 기존 46개도 계속 수집한다. 시험 호출 1건은 정상 응답했다. 대시보드 제목의 오타도 고쳤다. 수집은 10월 24일 07:00 실행부터 시작하며, 첫 값은 색인 반영 전 기준선이다. API 순위와 웹 순위는 JSON에만 기록하고 대시보드에는 표시하지 않는다. 문서 담당자는 인계 대기 항목도 닫았다. 운영팀은 10월 29일에 기준선과 비교해 방향을 보되, 색인 반영에 며칠이 걸리므로 최종 판단은 하지 않는다. 사용자가 지금 해야 할 일은 없다. 검색 노출 효과는 아직 확인하지 않았다.

## C6

$break-it-down C1의 가상 캐시 모델에서 10분을 기다렸는데도 저장된 값이 그대로였어. 왜 그런지 처음 배우는 사람에게 한국어 글로 설명해줘. 예시는 첫 조회가 09:00이고, 그 뒤 09:10까지 요청이 없었던 경우로 해줘.

가상 캐시 모델: 처음 조회한 결과를 조회 시각과 함께 저장한다. 다음 요청 시 저장 후 경과 시간이 300초 미만이면 저장된 결과를 사용한다. 300초 이상이면 그 요청에서 원본을 다시 조회하고 저장 시각을 바꾼다. 요청이 없으면 시간이 지나도 다시 조회하지 않는다. 모든 시각은 하나의 시계로 측정한다고 가정한다.
