# AgentSkills

[English](README.md)

Codex, Claude Code, OpenCode, 그리고 open agent skills 형식을 지원하는 다른 에이전트에서 재사용할 수 있는 스킬 모음입니다.

스킬은 최상위 `skills/`에서 관리하고 `skills` CLI로 필요한 것만 선택 설치합니다. 플러그인은 개별 훅 또는 모든 스킬·훅을 포함한 전체 묶음을 제공합니다. Codex와 Claude Code에서 같은 두 가지 플러그인을 선택할 수 있습니다.

## 스킬

- `apple-app-icon-generator`: Apple 앱 아이콘을 생성하고 설치하며, Debug와 Release의 번들 ID가 다를 때만 서로 닮은 Debug 변형을 추가합니다.
- `apple-bundle-id-guardrails`: 조직 App ID가 잘못 등록되지 않도록 보호하고, 개인·추가 팀·조직의 Release/Debug 번들 ID와 서명 팀을 분리해 설정합니다.
- `docs-sync`: 문서와 코드의 일치 여부를 점검합니다. 갱신 요청은 문서 수정이나 문서 기준 코드 수정까지 수행하고 검증합니다.
- `flutter-flavors`: Flutter flavor, `flutter_flavorizr` / `flavorizr.yaml`, 플랫폼 앱 identity, launch config, build mode 경계를 설정하거나 점검합니다.
- `git-workflow`: staging, commit, branch, merge, rebase, tag, recovery 같은 안전한 로컬 Git workflow를 안내합니다. 기본값으로 DCO sign-off를 포함한 서명 커밋(`git commit -S --signoff`)을 사용하며, 서명이 불가능하면 명시적인 fallback을 따릅니다.
- `github-workflow`: PR, 선택적 gh-stack을 통한 stacked PR, review, check, release, fork upstream 동기화 workflow를 안내합니다. CLI 도구가 없으면 설치 방법과 사용 가능한 연동 도구·브라우저 경로를 안내합니다.
- `macos-dev-app-cleanup`: 프로젝트의 macOS Debug·Dev·QA 앱을 정확한 경로로 식별해 정리하거나 삭제 여부를 확인하고, Release·사용자 데이터·공유 설정은 보존합니다.
- `css-typography-ko`: CSS로 한국어 웹 UI의 가독성을 개선합니다. 텍스트 위계, 글꼴과 간격, 어절 단위 줄바꿈, 줄 길이 조정, 긴 텍스트의 넘침 처리를 함께 다룹니다.
- `break-it-down`: 독자가 막히는 질문에서 출발해 원리와 관계를 설명합니다. 구체적인 사례·도해·인터랙티브 모델·설명 영상으로 변화의 이유와 적용 조건을 이해하게 돕습니다.

## 사용 예시

- `$apple-app-icon-generator 이 Xcode 프로젝트의 앱 아이콘을 만들고, 두 빌드를 함께 설치할 때만 Debug 변형도 추가해줘.`
- `$apple-bundle-id-guardrails 이 새 Xcode 프로젝트에 번들 ID 가드레일을 설정해줘.`
- `$docs-sync 이 diff에 맞춰 문서 업데이트가 필요한지 확인해줘.`
- `$flutter-flavors Android/iOS flavor를 점검하고 flavorizr.yaml이 native 파일과 맞는지 확인해줘.`
- `$git-workflow 지금 변경사항을 안전한 commit 단위로 나누는 걸 도와줘.`
- `$github-workflow 이 PR의 check와 merge 가능 상태를 검토해줘.`
- `$github-workflow 이 기능을 의존하는 PR 여러 개로 나눠줘. gh-stack이 없으면 설치 없이 진행해줘.`
- `$github-workflow 내 저장소의 main 브랜치를 upstream main과 매일 4시에 동기화하는 workflow 만들어줘.`
- `$macos-dev-app-cleanup 이 프로젝트의 macOS 테스트 앱을 정리해줘. 설치된 Release와 공유 설정은 남겨줘.`
- `$css-typography-ko 이 한국어 웹 UI의 기존 디자인을 유지하면서 가독성, 텍스트 위계, 행간과 줄바꿈을 다듬어줘.`
- `$break-it-down 지금 이야기한 내용을 이해하기 쉽게 만들어줘. 효과적인 형식을 골라 실제 결과물까지 보여줘.`
- `$break-it-down 글: 이 안내문의 조건과 예외를 보존하면서 설명해줘.`
- `$break-it-down 그림: 이 과정의 관계와 분기를 보여줘.`
- `$break-it-down 웹: 금리와 기간을 바꾸며 복리를 살펴볼 수 있게 만들어줘.`
- `$break-it-down 영상: 이 과정을 한국어 내레이션과 자막이 있는 60초 영상으로 만들어줘.`

기존 `explain` 스킬의 이름을 `break-it-down`으로 바꿨습니다. 앞으로는 `$break-it-down`으로 호출합니다. 이름만 입력하면 현재 대화의 주제를 사용합니다. 형식은 자연어로 지정할 수 있습니다. 제작에는 환경에서 사용할 수 있는 도구를 쓰며, 렌더러나 음성 엔진을 스킬에 포함하지는 않습니다. 영어 기술 설명에는 STE에서 가져온 작성 기준을, 한국어에는 별도의 언어 지침을 적용합니다. 영어 STE 준수 검토에는 공식 규칙과 사전을 확인합니다.

화면을 구성하기 전에 설명할 관계와 원리를 정하고, 설명의 논리와 산출물의 동작을 각각 확인합니다. 인터랙티브 설명은 결과와 함께 영향을 받는 관계나 과정을 보여줍니다. 대본만 요청하면 검토한 대본으로 끝내고, 완성 영상을 요청하면 렌더링과 재생까지 확인합니다. [행동 검증 사례와 확인 기록](docs/break-it-down/cases.md)은 설치되는 스킬 밖에서 관리합니다.

## 빠른 설치

스킬을 설치할 프로젝트 폴더에서 다음 명령을 실행하세요.

```bash
npx skills@latest add mabyko/AgentSkills
```

기본적으로 `npx skills add`는 프로젝트 단위로 설치합니다. 사용자 전역 설치가 필요할 때만 `--global`을 사용하세요.

## 코딩 원칙 설치

Bash 3.2 이상과 기본 Unix 명령으로 동작하며, 원격 설치에는 curl이 필요합니다. Python·Node는 필수가 아닙니다. Node.js 22.20 이상이 있으면 skills CLI의 검색 선택 화면과 Clack의 범위·요약·확인 화면을 사용하고, 없으면 Bash 화면을 사용합니다. 팀원은 저장소를 내려받지 않고 한 줄로 설치할 수 있습니다.

```bash
curl -fsSL https://raw.githubusercontent.com/mabyko/AgentSkills/main/scripts/install-coding-principles.sh | bash
```

이미 내려받은 저장소에서는 지금 `./scripts/install-coding-principles.sh`로 실행할 수 있습니다. Space로 에이전트를 선택하고 전역·프로젝트 범위를 고른 뒤, 지침 파일 경로를 확인하고 적용하세요. Node 화면에서는 이름을 입력해 목록을 검색하고 선택한 도구를 요약해서 볼 수 있습니다. 방향키로 이동하고 Enter로 진행합니다. Esc·Ctrl-C로 취소할 수 있습니다. Bash 화면에서는 q로도 취소할 수 있지만, Node의 검색 목록에서는 q도 검색어로 입력됩니다.

Clack 화면은 필요한 라이브러리를 포함한 파일로 배포하므로 실행할 때 npm으로 설치할 필요가 없습니다. 원격 실행에서는 선택 전에 이 파일을 내려받고 종료 시 지웁니다. 다운로드나 로딩에 실패하면 Bash 화면을 사용합니다. 두 화면 모두 같은 Bash 코드로 설치·제거합니다.

Codex·Claude Code·Grok Build·Antigravity·OpenCode·Pi 중 여러 도구를 고를 수 있습니다. 처음에는 개인 전역 범위와 Codex·Claude Code가 선택돼 있습니다. 프로젝트에서 같은 지침 파일을 쓰는 도구들은 원칙 블록을 한 번만 추가합니다.

자동화에서는 `--yes`로 기본값을 바로 적용하세요. `--scope`·`--agent`·`--project-dir`를 지정해도 선택 화면을 건너뜁니다. 지정한 옵션을 선택 화면에서 바꾸려면 `--interactive`를 붙이세요. `--agent codex,opencode,pi`처럼 여러 도구를 쉼표로 구분하거나, `--agent all`로 여섯 도구를 모두 지정할 수 있습니다. 터미널이 없으면 옵션으로 바꾸지 않는 한 개인 전역 범위에 Codex·Claude Code를 설치합니다.

전체 옵션과 예시를 보거나, Codex에 전역 설치하거나, 그 선택을 화면에서 확인하려면:

```bash
./scripts/install-coding-principles.sh --help
./scripts/install-coding-principles.sh --scope global --agent codex
./scripts/install-coding-principles.sh --interactive --scope global --agent codex
```

프로젝트에 설치해 팀과 공유하려면:

```bash
./scripts/install-coding-principles.sh --scope project --project-dir /path/to/project
```

`--project-dir`는 `--scope project`와 함께 써야 합니다. 생략하면 현재 폴더를 사용합니다. Codex만 설치하려면 `--agent codex`를 추가하세요.

프로젝트의 `AGENTS.md`·`CLAUDE.md` 변경을 검토하고 커밋하면 팀원은 프로젝트를 내려받아 같은 원칙을 사용합니다.

같은 선택 화면에서 제거할 범위와 도구를 고르려면:

```bash
./scripts/install-coding-principles.sh uninstall
```

반복 설치는 원칙 블록만 갱신하고, 제거는 그 블록만 지웁니다. 기존 지침은 보존합니다. [원칙](docs/coding-principles.md)과 [설치·업데이트·프로젝트 제거 안내](docs/coding-principles-install.md)를 참고하세요. 적용 후 새 세션을 시작하세요.

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

참고: `skills` CLI는 스킬만 설치합니다. 이 저장소의 [훅](#훅)은 `skills/` 바깥에 있어서 플러그인 설치 경로로만 배포됩니다. 훅이 필요하면 아래 플러그인 설치 방법을 사용하세요.

## 플러그인 선택

같은 `mabyko` marketplace에서 전체 묶음이나 필요한 플러그인을 선택하세요.

| 플러그인 | 포함하는 기능 |
| --- | --- |
| `agent-skills` | 전체 묶음: 스킬 9개 + Git 안전 훅 |
| `git-hooks` | Git 안전 훅(`PreToolUse`)만 포함. 스킬 없음 |

필요한 스킬은 `skills` CLI에서 이름으로 선택하세요. 예를 들어 Git과 GitHub 스킬만 설치하려면:

```bash
npx skills@latest add mabyko/AgentSkills --skill git-workflow github-workflow
```

모든 스킬과 훅을 한 번에 설치하려면 `agent-skills` 하나를 선택하세요. 전체 묶음과 개별 스킬·훅을 함께 설치하면 중복 등록될 수 있습니다.

자동 실행 알림은 `git-hooks` 플러그인으로 별도 설치합니다. 스킬 없이도 동작하며 독립적으로 제거할 수 있습니다. 아래 명령의 `agent-skills`를 `git-hooks`로 바꾸면 됩니다.

### 스킬과 훅의 역할

모든 스킬은 단독으로 사용할 수 있습니다. 다음 분류는 설치 의존성이 아니라 훅이 보완하는 역할을 나타냅니다.

| 스킬 | 분류 | 판단 근거 |
| --- | --- | --- |
| `git-workflow` | 스킬 + 선택 훅 | 스킬은 Git 작업·복구 절차를 안내하고, Git 훅은 Bash 명령 직전에 핵심 안전 규칙을 상기시킵니다. |
| `github-workflow` | 스킬만으로 충분 | PR·리뷰·CI·릴리스는 작업 맥락이 필요합니다. Git 훅은 직접 실행하는 gh/API 작업을 다루지 않습니다. |
| `apple-app-icon-generator` | 스킬만으로 충분 | 앱 식별, 디자인 선택, 생성·설치·확인은 요청별 절차입니다. |
| `apple-bundle-id-guardrails` | 스킬만으로 충분 | 번들 ID와 서명 팀의 소유권·설정은 프로젝트 맥락으로 판단합니다. |
| `macos-dev-app-cleanup` | 스킬만으로 충분 | 승인된 삭제 범위와 정확한 앱 경로를 먼저 확인해야 합니다. |
| `flutter-flavors` | 스킬만으로 충분 | flavor 의도와 플랫폼 설정을 함께 점검하는 작업입니다. |
| `docs-sync` | 스킬만으로 충분 | 변경사항과 문서가 약속한 동작을 비교해야 합니다. |
| `css-typography-ko` | 스킬만으로 충분 | 텍스트 위계와 화면 가독성을 실제 UI에서 확인해야 합니다. |
| `break-it-down` | 스킬만으로 충분 | 독자의 질문과 설명할 관계에 따라 절차·형식을 선택합니다. |

스킬 설치는 내용을 매 세션에 전부 넣는 방식이 아닙니다. 호출하거나 설명에 맞는 작업을 만났을 때 스킬을 읽습니다. 훅은 지정한 이벤트에 실행됩니다. Git 훅은 Bash 명령 일부를 감지하는 알림이며 모든 위험 작업을 차단하는 장치는 아닙니다.

## Codex 플러그인

개인 전역 설치:

```bash
codex plugin marketplace add mabyko/AgentSkills
codex plugin add agent-skills@mabyko
```

`/plugins`에서도 설치할 수 있습니다. 훅을 포함한 플러그인은 설치 후 `/hooks`에서 훅을 검토하고 신뢰하도록 설정하세요. 설치만으로 훅이 신뢰되지는 않으며, 훅 정의가 추가·변경되면 재검토가 필요할 수 있습니다. [Codex 훅 문서](https://learn.chatgpt.com/docs/hooks)를 참고하세요.

특정 프로젝트에서만 쓰려면 설치본은 유지하고 사용자 설정(`$CODEX_HOME/config.toml`, 기본 `~/.codex/config.toml`)에 다음을 설정합니다.

```toml
[plugins."agent-skills@mabyko"]
enabled = false
```

사용할 프로젝트의 `.codex/config.toml`에는 같은 항목을 `enabled = true`로 설정하세요. 프로젝트 설정은 신뢰한 프로젝트에서만 적용됩니다. 해당 프로젝트에서 끄려면 값을 다시 `false`로 바꾸세요. 이 설정은 스킬과 다른 훅을 포함한 플러그인 전체에 적용됩니다. [Codex 설정 우선순위](https://developers.openai.com/codex/config-basic/)를 참고하세요.

개인 전역 설치 제거:

```bash
codex plugin remove agent-skills@mabyko
```

Codex는 `.agents/plugins/marketplace.json`과 선택한 플러그인의 `.codex-plugin/plugin.json`을 읽습니다. `agent-skills`의 루트는 저장소 루트이고, 선택 플러그인의 루트는 `plugins/<이름>/`입니다. 각 플러그인은 자신에게 등록된 스킬과 훅을 로드합니다.

## Claude Code 플러그인

marketplace 등록 후 개인 전역 설치:

```bash
claude plugin marketplace add mabyko/AgentSkills
claude plugin install agent-skills@mabyko --scope user
```

프로젝트 범위로 설치하려면 해당 프로젝트 폴더에서 실행하세요.

```bash
claude plugin install agent-skills@mabyko --scope project
```

설치한 범위와 같은 범위를 지정해 제거합니다.

```bash
claude plugin uninstall agent-skills@mabyko --scope user
# 또는 해당 프로젝트 폴더에서:
claude plugin uninstall agent-skills@mabyko --scope project
```

두 범위에 설치했다면 각각 제거하세요. 프로젝트 설치는 팀과 공유하는 프로젝트 설정에 기록됩니다. 자신의 프로젝트 사본에만 적용하려면 `--scope local`을 사용하세요. [Claude Code 플러그인 CLI 문서](https://code.claude.com/docs/en/plugins/cli-reference)를 참고하세요.

Claude Code는 `.claude-plugin/marketplace.json`(marketplace 이름 `mabyko`)과 선택한 플러그인의 `.claude-plugin/plugin.json`을 읽습니다. 스킬과 `hooks/hooks.json`은 해당 플러그인의 루트 안에서 찾습니다.

플러그인 설치본은 도구에서 캐시될 수 있으므로 최신 버전은 플러그인 관리자에서 갱신하거나 재설치하세요. 이 저장소의 `CLAUDE.md`는 `@AGENTS.md`를 가져와 작성 지침을 공유합니다.

## 훅

`agent-skills`와 `git-hooks`는 기존 `PreToolUse` 훅을 설치합니다. Bash로 실행되는 위험한 Git 명령 앞에서 `git-workflow` 스킬의 안전 규칙을 알려줍니다. 카테고리별로 세션당 한 번씩 알리므로, 세션 초반의 `git checkout`이 나중에 필요한 `git commit` 알림을 삼키지 않습니다.

| 카테고리 | 트리거 | 알리는 내용 |
| --- | --- | --- |
| History | `commit`, `rebase`, `merge`, `cherry-pick`, `revert`, `tag`, `push`, `reflog`, `am` | DCO sign-off를 포함한 서명 커밋, atomic commit, 커밋 본문 작성, `--no-verify` / `--no-gpg-sign` 금지, `--force-with-lease`만 사용 |
| Discard | `reset`, `clean`, `restore`, `checkout`, `switch`, `stash`, `worktree remove`, `branch -d/-D` | 먼저 `git status` 확인, 커밋 안 된 작업을 버리거나 ref를 지우기 전 확인, `stash`와 `revert` 우선 |

이 `PreToolUse` 훅은 두 도구가 읽는 필드가 달라서 동작도 다릅니다.

- Claude Code는 실행을 막지 않는 `additionalContext` 힌트를 받습니다.
- Codex는 첫 매칭 명령을 한 번 deny해서 이유를 보여주고, 재시도는 허용합니다.

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
├── marketplace.json
└── plugin.json
.agents/
└── plugins/marketplace.json
.github/
└── workflows/validate.yml
hooks/
└── hooks.json
codex-hooks/
└── hooks.json
templates/
└── skill/
scripts/
├── new-skill.sh
├── install-coding-principles.sh
├── coding-principles-ui.mjs
├── coding-principles-ui.cjs      # Clack 배포본; 실행 시 npm 설치 불필요
├── build-coding-principles-ui.mjs
├── build-plugin-bundles.py
├── validate-skills.sh
└── hooks/
plugins/
└── git-hooks/            # PreToolUse only
tests/
├── test_coding_principles_installer.py
├── test_git_hooks.py
└── test_plugin_bundles.py
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

훅 플러그인에는 설치 후 독립적으로 동작하도록 생성한 배포본이 들어갑니다. 원본 스킬은 `skills/`, 공통 훅은 `scripts/hooks/`에서 수정한 뒤 배포본을 갱신하세요.

```bash
python3 scripts/build-plugin-bundles.py
```

작성 환경에는 Python 3.9 이상이 필요합니다. 삭제된 파일이나 실행 권한을 포함해 원본과 배포본이 다르면 검증에 실패합니다. 내용이 바뀌면 전체 묶음과 영향을 받은 훅 플러그인의 두 호스트 버전을 함께 올리세요.

선택형 Node 화면을 바꾸려면 `scripts/coding-principles-ui.mjs`를 수정한 뒤 의존성 라이선스를 포함한 배포본을 다시 생성하세요. 검색 선택 화면은 skills CLI의 특정 커밋에서 가져온 `scripts/vendor/skills-search-multiselect.ts`를 사용합니다. MIT 라이선스를 유지하며, 터미널 입출력과 취소 신호를 연결한 부분만 수정했습니다. 이 작성 단계에는 Node.js 22.20 이상과 npm이 필요합니다.

```bash
npm ci --ignore-scripts
npm run build:coding-principles-ui
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
