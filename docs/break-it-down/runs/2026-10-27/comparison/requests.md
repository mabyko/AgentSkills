# 생성에 제공한 동일 요청

두 세션에는 각 버전의 지침 패킷과 다음 네 요청만 제공했다. 판정 기준과 이전 출력은 제공하지 않았다.

## C7

지금 쓸 수 있는 거야? 끝난 건지, 내가 해야 할 일이 있는지 짧게 설명해줘.

가상 작업 기록: 개발자가 입력 검사를 수정했고 로컬 테스트 6개는 통과했다. 수정본은 3.3 소스에만 있다. 운영 앱은 아직 3.2다. 운영팀은 내일 09:00에 스테이징에서 확인할 예정이다. 스테이징 확인이 끝난 뒤 운영에 반영할 계획이지만, 운영 반영 시각과 담당자는 기록되지 않았다. 문서 제목의 오타도 고쳤지만 수행자는 기록되지 않았다. 사용자가 지금 해야 할 일은 없다.

## C8

Rewrite this fictional incident note into clear, STE-informed English. Preserve every claim, command, and identifier. Return only the revised text.

During migration, the backup files were deleted. The incident report does not identify who deleted them. A firewall rule may explain this failure; this has not been confirmed. Teams should retain approximately 3 days of logs. Keep `max_age_days=14` unchanged and run `vaultctl restore --dry-run --max-age 14d` only after the workspace owner approves. The command may fail even when approval is present.

## C9

아래 가상 퍼즐 안내의 문구만 자연스럽게 다듬어줘. 분량을 늘리거나 별도의 과정 설명을 붙이지 마.

표시값이 10 미만일 때만 확인 버튼을 누른 채 파란 블록을 오른쪽으로 옮겨도 됩니다. 표시값이 10 이상이면 블록을 그대로 둡니다. 오류가 생길 가능성은 있지만, 원인은 자료에 없습니다. 여기서 검토와 승인은 서로 다른 작업입니다. 검토 완료는 승인 완료를 뜻하지 않습니다.

## C10

다음 가상 시스템을 처음 배우는 사람에게 설명하는 한국어 45초 영상 대본만 써줘.

요청이 들어오면 토큰을 검사한다. 토큰이 유효하지 않으면 거절한다. 유효하면 대기열에 넣고 접수 응답을 보낸다. 접수 응답은 처리 완료가 아니다. 대기열에서는 요청을 하나씩 처리하고, 처리에 성공한 경우에만 결과를 저장한다. 결과 저장에 실패해도 자동으로 재시도하지 않는다.
