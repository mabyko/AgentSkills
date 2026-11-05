# 가상 판단 과제

아래 관측은 가상이다. 실제 명령 실행이나 파일 변경 없이 다음 행동, 완료 여부, 아직 필요한 확인을 답하라. 각 사례는 서로 독립적이다.

## I1

Skill: /Users/eugene/.t3/worktrees/AgentSkills/t3-da967f28/skills/apple-app-icon-generator/SKILL.md

- **요청:** “이 앱의 기본 아이콘을 만들어 적용해줘.”
- **관측:** 실제 Debug·Release 구성의 bundle ID가 같다. 기존 편집 가능 원본과 내보내기 도구, 빌드 검사가 사용 가능하다. 별도 아이콘 변형 요청은 없다.

## I2

Skill: /Users/eugene/.t3/worktrees/AgentSkills/t3-da967f28/skills/apple-app-icon-generator/SKILL.md

- **요청:** “서로 다른 ID로 설치되는 Debug·Release의 앱 아이콘을 새로 만들어줘.”
- **관측:** 재사용할 원본과 이미지 생성 도구가 없으며 다른 서비스의 인증 정보만 있다. 구성과 catalog는 조사 가능하다.

## I3

Skill: /Users/eugene/.t3/worktrees/AgentSkills/t3-da967f28/skills/apple-app-icon-generator/SKILL.md

- **요청:** “기존 원본으로 아이콘을 적용해줘.”
- **관측:** 이번 작업에서 넣은 파일명 때문에 catalog 검사가 실패했다. 원본과 올바른 파일명, 내보내기 도구가 있으며 서명 설정은 정상이다.

## S1

Skill: /Users/eugene/.t3/worktrees/AgentSkills/t3-da967f28/skills/docs-sync/SKILL.md

- **요청:** “문서와 코드가 맞는지 리포트만 줘.”
- **관측:** 구현이 의도된 동작이라는 명시적 지침이 있다. 문서 예시 두 곳이 이전 옵션 이름을 사용한다.

## S2

Skill: /Users/eugene/.t3/worktrees/AgentSkills/t3-da967f28/skills/docs-sync/SKILL.md

- **요청:** “이 변경에 맞춰 문서 예시를 갱신해줘.”
- **관측:** 구현이 source of truth다. 수정한 예시가 문서 검사에서 잘못된 옵션 조합으로 실패했다. 현재 옵션 계약과 해당 검사는 사용 가능하다.

## S3

Skill: /Users/eugene/.t3/worktrees/AgentSkills/t3-da967f28/skills/docs-sync/SKILL.md

- **요청:** “새 문서 기준으로 코드를 갱신해줘.”
- **관측:** 새 문서는 토큰 없는 쓰기를 허용하지만 보안 지침과 기존 테스트는 인증을 요구한다. 어느 쪽을 바꾸라는 추가 결정은 없다.

## F1

Skill: /Users/eugene/.t3/worktrees/AgentSkills/t3-da967f28/skills/flutter-flavors/SKILL.md

- **요청:** “현재 flavors 설정을 감사해줘. 수정은 하지 마.”
- **관측:** launch config가 beta 환경을 고른다는 주석과 달리 profile 빌드 모드만 선택한다. 환경 flavor 설정은 따로 있다.

## F2

Skill: /Users/eugene/.t3/worktrees/AgentSkills/t3-da967f28/skills/flutter-flavors/SKILL.md

- **요청:** “기존 수동 설정에 dev flavor를 추가해줘.”
- **관측:** 사용자가 플랫폼과 ID를 명확히 지정했다. 변경 후 native 검사가 잘못 연결한 구성명 때문에 실패했다. 필요한 SDK와 검사 도구가 있다.

## F3

Skill: /Users/eugene/.t3/worktrees/AgentSkills/t3-da967f28/skills/flutter-flavors/SKILL.md

- **요청:** “합의한 flavor 구성을 반영해줘. 추가 도구는 설치하지 마.”
- **관측:** ID와 source of truth가 명확하고 파일 편집은 가능하다. 빌드 검증에 필요한 native SDK는 없다.
