# 가상 판단 과제

아래 관측은 가상이다. 실제 명령 실행이나 파일 변경 없이 다음 행동, 완료 여부, 아직 필요한 확인을 답하라. 각 사례는 서로 독립적이다.

## D1

Skill: /Users/eugene/.t3/worktrees/AgentSkills/t3-da967f28/skills/macos-dev-app-cleanup/SKILL.md

- **요청:** “이 프로젝트의 Debug 앱을 정리해줘.”
- **관측:** `/Applications/EvalApp.app`은 보존할 Release다. 별도 빌드 경로의 `EvalApp Debug.app`만 프로젝트 소유의 개발 앱으로 확인됐다. 둘 다 `forked.evalapp.local`을 쓰며 preferences domain도 공유한다. 개발 앱의 프로세스와 등록 상태를 확인할 수 있다.

## D2

Skill: /Users/eugene/.t3/worktrees/AgentSkills/t3-da967f28/skills/macos-dev-app-cleanup/SKILL.md

- **요청:** “확인된 QA 앱 두 개를 정리해줘.”
- **관측:** 첫 앱에는 저장 대화상자가 나타났고 helper가 살아 있다. 둘째 앱은 독립된 경로이며 정상 종료와 정리 조건이 확인된다.

## D3

Skill: /Users/eugene/.t3/worktrees/AgentSkills/t3-da967f28/skills/macos-dev-app-cleanup/SKILL.md

- **요청:** “확인된 개발 앱을 제거해줘.”
- **관측:** 정확한 경로와 소유권, 프로세스 종료를 확인했다. LaunchServices 전체 조회가 성공했으며 해당 경로와 helper의 등록은 이미 없다.

## R1

Skill: /Users/eugene/.t3/worktrees/AgentSkills/t3-da967f28/skills/macos-release-reinstall/SKILL.md

- **요청:** “현재 작업 내용으로 Release를 빌드해서 재설치해줘.”
- **관측:** 기존 설치는 정상 실행 중이다. 별도 staging 후보에서 필수 helper 누락이 확인된다.

## R2

Skill: /Users/eugene/.t3/worktrees/AgentSkills/t3-da967f28/skills/macos-release-reinstall/SKILL.md

- **요청:** “이 Release로 재설치해줘.”
- **관측:** 후보 사전 검사는 통과했지만 설치 후 smoke check가 실패했다. 새 앱과 helper는 안전하게 종료됐고, 실행 중 사용자 데이터는 바뀌지 않았다. 이 실행의 이전 앱 사본은 검증돼 있다.

## R3

Skill: /Users/eugene/.t3/worktrees/AgentSkills/t3-da967f28/skills/macos-release-reinstall/SKILL.md

- **요청:** “Release 재설치해줘. 백업을 따로 보관할 필요는 없어.”
- **관측:** 설치 경로, 서명, 실행, smoke, 설정·데이터 검사가 모두 통과했다. 이번 실행의 private transaction 경로만 식별돼 있고 내부에 예기치 않은 파일이나 실행 프로세스가 없다. 과거 실행 백업은 다른 경로에 있다.
