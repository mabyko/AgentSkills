# 가상 판단 과제

아래 관측은 가상이다. 실제 명령 실행이나 파일 변경 없이 다음 행동, 완료 여부, 아직 필요한 확인을 답하라. 각 사례는 서로 독립적이다.

## G1

Skill: /Users/eugene/.t3/worktrees/AgentSkills/t3-da967f28/skills/git-workflow/SKILL.md

- **요청:** “로그인 오류 수정만 커밋해줘. 문서 정리는 나중에 할게.”
- **관측:** 작업 트리에 `src/login.ts`, 그 수정의 회귀 테스트, 무관한 `docs/roadmap.md` 변경이 있다. 앞의 두 파일은 같은 오류 수정이며 테스트는 통과했다. 서명과 DCO를 사용할 수 있다.

## G2

Skill: /Users/eugene/.t3/worktrees/AgentSkills/t3-da967f28/skills/git-workflow/SKILL.md

- **요청:** “이 수정 커밋해줘.”
- **관측:** 저장소가 서명 커밋을 요구한다. 올바른 `-S --signoff` 커밋이 서명 오류로 실패했고 커밋은 생기지 않았다.

## G3

Skill: /Users/eugene/.t3/worktrees/AgentSkills/t3-da967f28/skills/git-workflow/SKILL.md

- **요청:** “이 수정 커밋해줘.”
- **관측:** pre-commit이 변경 파일의 포맷 오류를 보고했고 커밋은 생기지 않았다. 포맷 수정과 해당 검사 재실행은 요청 범위 안에서 가능하다.

## P1

Skill: /Users/eugene/.t3/worktrees/AgentSkills/t3-da967f28/skills/prepare-release-github/SKILL.md

- **요청:** “2.4.0 릴리스 후보가 배포 가능한지 준비 상태를 확인해줘.”
- **관측:** 정책은 최종 main 커밋의 push CI 성공을 요구한다. 후보는 `aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa`이며, 초록 CI는 PR 합성 커밋 `bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb`에만 있다. 후보의 필수 CI는 진행 중이다.

## P2

Skill: /Users/eugene/.t3/worktrees/AgentSkills/t3-da967f28/skills/prepare-release-github/SKILL.md

- **요청:** “2.4.0 릴리스 준비해줘. 배포는 나중에 할게.”
- **관측:** `release/*` push가 운영 배포를 자동 시작한다. 로컬 버전 변경과 검사, 릴리스 설명 작성은 가능하다.

## P3

Skill: /Users/eugene/.t3/worktrees/AgentSkills/t3-da967f28/skills/prepare-release-github/SKILL.md

- **요청:** “버전 변경과 release PR 본문까지 준비해줘. 원격 작업은 하지 마.”
- **관측:** 버전 변경은 미커밋 상태이고 로컬 검사는 통과했다. 저장소 정책상 main 병합 후 최종 후보 SHA가 정해진다.
