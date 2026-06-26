# AgentSkills

[English](README.md)

Codex, Claude Code, OpenCode, 그리고 open agent skills 형식을 지원하는 다른 에이전트에서 재사용할 수 있는 스킬 모음입니다.

이 저장소의 canonical skill source는 최상위 `skills/` 디렉터리입니다. 플러그인 manifest와 marketplace 파일도 같은 source를 가리키므로, 여러 에이전트 생태계에서 동일한 스킬을 설치할 수 있습니다.

## 스킬

- `docs-sync`: 사용자에게 보이는 코드 변경에 맞춰 문서를 동기화하거나, 문서가 의도된 코드 동작을 정의하는지 확인합니다.
- `git-workflow`: staging, commit, branch, merge, rebase, tag, recovery 같은 안전한 로컬 Git workflow를 안내합니다.
- `github-workflow`: pull request, review thread, Actions check, release, `gh` CLI 사용 같은 GitHub 협업 workflow를 안내합니다.
- `github-upstream-sync`: fork 저장소를 upstream과 동기화하는 GitHub Actions workflow를 만들거나 검토합니다.

## 사용 예시

- `$docs-sync 이 diff에 맞춰 문서 업데이트가 필요한지 확인해줘.`
- `$git-workflow 지금 변경사항을 안전한 commit 단위로 나누는 걸 도와줘.`
- `$github-workflow 이 PR의 check와 merge 가능 상태를 검토해줘.`
- `$github-upstream-sync 내 저장소의 main 브랜치를 upstream main과 매일 4시에 동기화하는 workflow 만들어줘.`

## 빠른 설치

스킬을 설치할 프로젝트 폴더에서 다음 명령을 실행하세요.

```bash
npx skills@latest add mabyko/AgentSkills
```

기본적으로 `npx skills add`는 프로젝트 단위로 설치합니다. 사용자 전역 설치가 필요할 때만 `--global`을 사용하세요.

## 설치된 스킬 업데이트

이미 `skills` CLI로 이 스킬들을 설치한 프로젝트에서는 update 명령을 사용하세요.

```bash
npx skills@latest update
```

`skills update`는 설치된 스킬 lock file을 읽고, 최신 source를 가져온 뒤, 기존 설치본을 제거하고 업데이트된 버전을 다시 설치합니다. 따라서 upstream에서 삭제된 `references/` 파일이나 다른 bundled resource 파일도 설치본에서 함께 정리되는 방향으로 동작합니다.

처음 설치할 때는 `add`를 사용하세요.

```bash
npx skills@latest add mabyko/AgentSkills
```

## 설치 옵션

설치하지 않고 사용 가능한 스킬 목록만 확인:

```bash
npx skills@latest add mabyko/AgentSkills --list
```

특정 스킬만 설치:

```bash
npx skills@latest add mabyko/AgentSkills --skill docs-sync
```

특정 에이전트 대상으로 설치:

```bash
npx skills@latest add mabyko/AgentSkills -a claude-code -a codex -a opencode
```

전역 설치:

```bash
npx skills@latest add mabyko/AgentSkills --global
```

`skills` CLI는 이 저장소의 최상위 `skills/` 디렉터리를 찾아 선택한 스킬을 각 에이전트가 기대하는 위치에 설치합니다.

## Codex 플러그인

Codex marketplace에서 이 저장소를 플러그인으로 설치하려면 이 방법을 사용하세요.

```bash
codex plugin marketplace add mabyko/AgentSkills
```

그 다음 Codex에서 `/plugins`로 이동해 `agent-skills`를 검색하고 설치합니다.

Codex는 이 저장소를 다음 경로로 해석합니다.

```text
.agents/plugins/marketplace.json
  └── source.path: "./"
      └── .codex-plugin/plugin.json
          └── skills: "./skills/"
```

marketplace 파일은 catalog entry이고, `.codex-plugin/plugin.json`은 플러그인 manifest입니다. 실제 스킬은 계속 `skills/`에 있습니다.

## Claude Code 플러그인

Claude Code에서 이 저장소를 플러그인으로 설치하려면 이 방법을 사용하세요.

```bash
/plugin marketplace add mabyko/AgentSkills
/plugin install agent-skills@agent-skills
```

Claude Code는 `.claude-plugin/plugin.json`을 플러그인 manifest로 읽고, 저장소의 최상위 `skills/` 디렉터리를 skill source로 사용합니다.

참고: 플러그인 설치본은 사용하는 도구에서 cache될 수 있습니다. 최신 스킬이 필요하면 해당 도구의 플러그인 manager에서 refresh, update, reinstall을 실행하세요.

`CLAUDE.md`에는 다음 내용이 있습니다.

```md
@AGENTS.md
```

이를 통해 Claude Code의 저장소 지침이 canonical instruction인 `AGENTS.md`와 맞춰집니다.

## 저장소 구조

```text
skills/
└── <skill-name>/
    ├── SKILL.md
    ├── agents/openai.yaml
    ├── references/
    ├── scripts/
    └── assets/
.codex-plugin/
└── plugin.json
.claude-plugin/
└── plugin.json
.agents/
└── plugins/marketplace.json
templates/
└── skill/
scripts/
├── new-skill.sh
└── validate-skills.sh
AGENTS.md
CLAUDE.md
```

## 기여

새 스킬은 반드시 최상위 `skills/` 디렉터리 아래에 만드세요. `.agents/skills/`, `.claude/skills/`, `plugins/` 아래에는 새 스킬을 추가하지 마세요.

새 스킬은 다음 명령으로 시작합니다.

```bash
scripts/new-skill.sh my-skill
```

이 명령은 다음 구조를 만듭니다.

```text
skills/my-skill/
├── SKILL.md
└── agents/openai.yaml
```

Pull request를 열기 전에:

1. `SKILL.md`에 명확한 `name`, trigger 중심의 `description`, 간결한 workflow를 작성합니다.
2. `agents/openai.yaml`에 display name, short description, brand color, `$my-skill`을 언급하는 `default_prompt`를 작성합니다.
3. 긴 예시, schema, 상세 reference 자료는 `references/`로 옮깁니다.
4. 결정적인 helper command는 스킬의 `scripts/` 디렉터리에 둡니다.
5. 재사용 가능한 template, image, static file은 스킬의 `assets/` 디렉터리에 둡니다.
6. validation을 실행합니다.

```bash
scripts/validate-skills.sh
```

스킬 이름은 `release-notes`, `frontend-review`, `python-debugging`처럼 kebab-case를 사용해야 합니다.

## 스킬 형식

각 스킬은 하나의 폴더이며 다음 항목을 포함할 수 있습니다.

- `SKILL.md`: 필수
- `agents/openai.yaml`: 선택, OpenAI/Codex UI metadata와 dependency 설정
- `scripts/`: 선택, 결정적인 helper command
- `references/`: 선택, 필요할 때만 불러오는 상세 문서
- `assets/`: 선택, 스킬이 사용하는 template, image, 기타 파일

## 라이선스

MIT
