# AgentSkills

[English](README.md)

Codex·Claude Code·OpenCode 등 공개 에이전트 스킬 형식을 지원하는 도구에서 사용할 수 있는 스킬 모음입니다. 필요한 구성을 골라 설치하세요.

| 구성 | 역할 | 설치 방법 |
| --- | --- | --- |
| [스킬](#스킬) | 직접 호출하거나 에이전트가 작업에 맞춰 선택하면 읽는 작업별 절차 | [Skills CLI](#스킬-설치) |
| [훅 플러그인](#훅-플러그인) | Codex·Claude Code에서 일부 Bash 명령 실행 전에 안전 규칙 안내 | 각 도구의 플러그인 관리자 |
| [코딩 원칙](#코딩-원칙) | 선택한 범위에서 읽는 기본 지침 파일에 코딩 규칙 추가 | Bash 설치기 |

각 구성은 독립적으로 설치합니다. 스킬이나 훅 플러그인을 설치해도 나머지 구성은 함께 설치되지 않습니다.

## 스킬 설치

프로젝트 폴더에서 실행한 뒤 스킬과 에이전트를 선택하세요.

```bash
npx skills@latest add mabyko/AgentSkills
```

기본 설치 범위는 프로젝트입니다. 목록 확인, 특정 스킬·에이전트 선택, 개인 전역 설치에는 다음 옵션을 사용하세요.

```bash
# 설치하지 않고 목록만 확인
npx skills@latest add mabyko/AgentSkills --list

# Git·GitHub 스킬만 설치
npx skills@latest add mabyko/AgentSkills --skill git-workflow github-workflow

# 설치할 에이전트 선택
npx skills@latest add mabyko/AgentSkills -a claude-code -a codex -a opencode

# 개인 전역 설치
npx skills@latest add mabyko/AgentSkills --global
```

CLI는 `skills/`에서 원본 스킬을 찾아 선택한 에이전트의 스킬 경로에 설치합니다. 설치된 스킬을 업데이트하려면:

```bash
npx skills@latest update
```

## 스킬

### Git·GitHub

- `git-workflow`: 스테이징, 커밋, 브랜치, 병합, 리베이스, 태그, 복구 등 로컬 Git 작업을 안내합니다. DCO sign-off를 포함한 서명 커밋(`git commit -S --signoff`)을 기본으로 사용하며, 서명할 수 없으면 대안을 명시합니다.
- `github-workflow`: PR, 선택형 gh-stack을 활용한 stacked PR, 리뷰, CI 확인, 릴리스, fork의 upstream 동기화를 안내합니다. CLI 도구가 없으면 설치 방법이나 다른 도구·브라우저 경로를 제시합니다.
- `prepare-release-github`: 저장소의 릴리스 규칙에 따라 버전, 릴리스 PR, 정확한 커밋의 CI 결과, 배포 인계 내용을 준비합니다. 게시·배포 실행 전에 끝납니다.

### Apple·Flutter

- `apple-app-icon-generator`: Apple 앱 아이콘을 생성하고 적용합니다. Debug와 Release의 bundle ID가 다르면 연결된 Debug 아이콘도 만듭니다.
- `apple-bundle-id-guardrails`: 조직 App ID를 보호하고, 안전한 xcconfig 기본값으로 개인·추가 팀·조직의 Release/Debug 식별자를 분리합니다.
- `macos-dev-app-cleanup`: 프로젝트의 macOS Debug·Dev·QA 앱을 정확한 경로로 제거하거나 제거 여부를 확인합니다. Release 앱, 사용자 데이터, 공유 설정은 보존합니다.
- `flutter-flavors`: Flutter flavor, `flutter_flavorizr`·`flavorizr.yaml`, 플랫폼별 앱 식별자, 실행 설정, 빌드 모드 경계를 구성하거나 점검합니다.

### 문서·UI·설명

- `docs-sync`: 문서와 코드의 일치 여부를 검토하거나, 요청한 문서 수정과 문서에 따른 코드 변경을 적용하고 확인합니다.
- `css-typography-ko`: 텍스트 위계, 글꼴, 간격, 단어 경계, 줄바꿈, 넘침 처리를 조정해 한국어 웹 UI의 가독성을 개선합니다.
- `break-it-down`: 질문과 그 이면의 작동 원리를 설명합니다. 예시, 다이어그램, 인터랙티브 모델, 내레이션 영상을 활용해 관계·변화·한계를 보여줍니다.

### 사용 예시

스킬을 직접 호출하거나 해당 작업을 자연어로 요청하세요.

```text
$git-workflow 이 변경사항을 안전하게 커밋 단위로 나눠줘.
$github-workflow 이 기능을 서로 의존하는 PR로 나눠줘.
$prepare-release-github 다음 릴리스와 배포 인계를 준비해줘. 배포 실행은 담당자에게 맡겨줘.
$apple-bundle-id-guardrails 이 Xcode 프로젝트의 bundle ID 보호 설정을 구성해줘.
$docs-sync 이 변경사항에 맞춰 문서도 수정해야 하는지 확인해줘.
$break-it-down diagram: 이 과정의 관계와 분기를 보여줘.
```

`break-it-down`은 기존 `explain`을 대체합니다. 주제를 생략하면 현재 대화를 바탕으로 설명하며, 글·다이어그램·인터랙티브 웹 모델·영상 중 원하는 형식을 자연어로 지정할 수 있습니다. 렌더링·음성 엔진을 포함하지 않고 실행 환경의 도구를 사용합니다. 대본을 요청하면 검토한 대본으로 끝내고, 완성 영상을 요청하면 렌더링과 재생까지 확인합니다. 형식별 안내, 언어 규칙, 검증 방법은 [스킬 지침](skills/break-it-down/SKILL.md)과 [행동 검증 사례](docs/break-it-down/cases.md)를 참고하세요.

## 훅 플러그인

`mabyko` marketplace에서 필요한 플러그인을 선택하세요.

| 플러그인 | 알림 내용 |
| --- | --- |
| `git-hooks` | Git 이력 변경, 작업 내용·ref 삭제 전 확인 사항 |
| `github-hooks` | GitHub PR 작성·병합, 스택 변경, 릴리스 변경 전 확인 사항 |
| `apple-dev-hooks` | Flutter Apple 빌드를 포함한 Apple 식별자·서명, macOS 개발 앱 정리 전 확인 사항 |

세 플러그인은 훅만 포함하며 스킬 없이도 동작합니다. 각 알림에 핵심 규칙을 넣고 관련 스킬이 있으면 읽도록 안내합니다. 플러그인이 스킬을 설치하거나 필수로 요구하거나 스킬의 절차를 자동 실행하지는 않습니다. 훅 규칙과 스킬 지침은 별도로 관리하며 실행 중에 자동 동기화되지 않습니다.

전체 작업 절차는 Git의 `git-workflow`, PR·스택·릴리스의 `github-workflow`, Apple 식별자의 `apple-bundle-id-guardrails`, 앱 정리의 `macos-dev-app-cleanup`, flavor 구성의 `flutter-flavors`가 안내합니다. `github-workflow`는 자동 선택을 허용하지만, 선택했을 때 본문을 읽고 필요한 참고 문서만 추가로 읽습니다. 훅은 감지한 명령 직전에 확인 사항을 알려주며 모든 확인이 수행됐음을 보장하지는 않습니다. Apple 플러그인이 아이콘을 생성하거나 flavor 설정을 바꾸지는 않습니다.

아래 명령은 `git-hooks` 예시입니다. 이름을 `github-hooks`나 `apple-dev-hooks`로 바꾸거나 필요한 플러그인을 각각 설치하세요.

### Codex

marketplace 등록 후 개인 계정에 설치합니다.

```bash
codex plugin marketplace add mabyko/AgentSkills
codex plugin add git-hooks@mabyko
```

`/plugins`에서도 설치할 수 있습니다. 설치 후 `/hooks`에서 훅을 검토하고 신뢰하도록 설정하세요. 설치만으로 훅이 신뢰되지는 않으며, 훅 정의가 추가·변경되면 다시 검토해야 할 수 있습니다. [Codex 훅 문서](https://learn.chatgpt.com/docs/hooks)를 참고하세요.

<details>
<summary>특정 프로젝트에서만 사용하기</summary>

설치본을 유지하고 사용자 설정(`$CODEX_HOME/config.toml`, 기본 `~/.codex/config.toml`)에서 끕니다.

```toml
[plugins."git-hooks@mabyko"]
enabled = false
```

사용할 프로젝트의 `.codex/config.toml`에는 같은 항목을 `enabled = true`로 설정하세요. 프로젝트 설정은 신뢰한 프로젝트에서만 적용됩니다. 해당 프로젝트에서 끄려면 다시 `false`로 바꾸세요. [Codex 설정 우선순위](https://developers.openai.com/codex/config-basic/)를 참고하세요.

</details>

설치한 플러그인 제거:

```bash
codex plugin remove git-hooks@mabyko
```

### Claude Code

marketplace 등록 후 개인 전역으로 설치합니다.

```bash
claude plugin marketplace add mabyko/AgentSkills
claude plugin install git-hooks@mabyko --scope user
```

팀과 공유하는 프로젝트 설치는 해당 프로젝트 폴더에서 실행하세요.

```bash
claude plugin install git-hooks@mabyko --scope project
```

자신의 프로젝트 사본에만 적용하려면 `--scope local`을 사용하세요. 제거할 때는 원래 설치한 범위를 지정합니다. 여러 범위에 설치했다면 각각 제거하세요.

```bash
claude plugin uninstall git-hooks@mabyko --scope user
# 또는 해당 프로젝트 폴더에서:
claude plugin uninstall git-hooks@mabyko --scope project
```

[Claude Code 플러그인 CLI 문서](https://code.claude.com/docs/en/plugins/cli-reference)를 참고하세요.

두 도구 모두 설치본을 캐시할 수 있습니다. 최신 버전은 각 도구의 플러그인 관리자에서 갱신하거나 재설치하세요.

### 훅 동작과 적용 범위

세 플러그인은 `PreToolUse`에 실행되며 종류별로 세션당 한 번씩 알립니다. Claude Code는 실행을 막지 않는 `additionalContext` 힌트를 받습니다. Codex는 첫 매칭 명령을 한 번 거부해 이유를 보여주고 재시도는 허용합니다. GitHub는 PR 작성·병합, 스택 이력·제출·병합, 릴리스를 각각 구분하므로 PR 작성이 나중의 병합 알림을 삼키지 않습니다.

<details>
<summary>감지하는 명령과 확인 사항</summary>

| 플러그인 / 종류 | 감지하는 명령 | 확인 사항 |
| --- | --- | --- |
| Git / 이력 | `commit`, `rebase`, `merge`, `cherry-pick`, `revert`, `tag`, `push`, `reflog`, `am` | DCO sign-off를 포함한 서명 커밋, 작업 단위로 나눈 커밋과 본문, `--no-verify`·`--no-gpg-sign` 금지, `--force-with-lease`만 사용 |
| Git / 삭제·폐기 | `reset`, `clean`, `restore`, `checkout`, `switch`, `stash`, `worktree remove`, `branch -d/-D` | 먼저 `git status` 확인, 커밋 안 된 작업이나 ref 삭제 전 확인, `stash`·`revert` 우선 |
| GitHub / PR 작성·변경 | `gh pr create/edit/ready/reopen/review/comment` | 정확한 저장소·head/base, PR 템플릿, draft 상태, 기존 스택 부모, 댓글·리뷰 게시 권한 |
| GitHub / PR 병합·닫기 | `gh pr merge/close` | 정확한 head와 작업 권한, CI·주석·리뷰, 브랜치 보호, 스택 소속, 요청한 병합 방식, 원격 결과 |
| GitHub / 스택 이력 | `gh stack init/add/rebase` | trunk·레이어 순서, 깨끗하고 작업 중이지 않은 worktree, 공유 이력 변경 권한, 암묵적 커밋을 포함한 서명·DCO |
| GitHub / 스택 제출·동기화 | `gh stack submit/push/sync` | remote·레이어 범위, 암묵적 rebase·force push, 별도 정리 권한, PR 템플릿, 동기화 후 실제 상태 |
| GitHub / 스택 병합 | `gh stack merge` | 함께 병합되는 전체 레이어, CI·리뷰·trunk 규칙, 스택을 유지하는 병합, 원격 결과 |
| GitHub / 릴리스 | `gh release create/edit/upload/delete/delete-asset` | 릴리스 규칙, 태그·대상 SHA·CI·자산, draft·latest 상태, 명시적인 게시·삭제 범위, 복구·원격 확인 |
| Apple / 식별자 | `xcodebuild`, `codesign` 서명, 일부 `xcrun simctl`·`devicectl` 설치·실행 명령, `flutter build ios/ipa/macos`, `ios`·`macos`를 명시한 `flutter run` | 각 타깃의 실제 bundle ID·서명 팀, 조직 ID 등록 여부, 개인 식별자 분리, Flutter flavor와 Xcode 설정 연결 |
| Apple / 정리 | `.app`·`DerivedData`·`build/macos`가 포함된 `rm`, 일부 `find` 앱 삭제, `lsregister -u`, `defaults delete` | 기존 삭제 권한, 정확한 앱 출처·경로, Release 앱·공유 데이터 보존, 정상 종료, 해당 경로만 등록 해제, 제거 확인 |

</details>

입력 텍스트로 감지하므로 인용한 예시에도 반응할 수 있고, 래퍼·변수·스크립트는 놓칠 수 있습니다. `git-hooks`는 Git 명령을, `github-hooks`는 위에 나열한 `gh pr`·`gh stack`·`gh release` 명령을 감지하며 스택 내부의 Git 변경도 안내합니다. `gh api`, MCP·브라우저 작업, 하위 명령 앞에 전역 옵션을 넣는 형태는 다루지 않습니다. `gh pr view/checks`·`gh stack view`·`gh release view` 같은 조회에는 알림을 띄우지 않습니다. Apple 플랫폼을 알 수 없는 Flutter 기기 ID도 감지하지 못할 수 있습니다. `xcodebuild` 조회 명령에 식별자 알림이 뜰 수 있지만, 요청한 조회에 추가 승인을 요구하지는 않습니다.

훅이 감지한 명령을 직접 실행하지는 않습니다. GitHub·Apple 세션 상태를 기록하지 못하면 stderr에 알리고 명령을 허용해 Codex 재시도가 막히지 않도록 합니다.

### 기존 전체 묶음에서 전환하기

전체 묶음인 `agent-skills`는 marketplace에서 제거했습니다. 이미 설치한 캐시는 자동으로 제거되지 않으므로 직접 제거하세요.

```bash
codex plugin remove agent-skills@mabyko
claude plugin uninstall agent-skills@mabyko --scope user
```

Claude Code는 원래 설치한 범위를 지정하세요. 이후 필요한 스킬과 훅 플러그인을 각각 설치합니다.

## 코딩 원칙

[코딩 원칙](docs/coding-principles.md)을 `AGENTS.md`·`CLAUDE.md` 등 도구의 기본 지침 파일에 추가합니다. 선택한 범위에서 스킬 호출 없이 적용됩니다. 저장소를 clone하지 않고 실행할 수 있습니다.

```bash
curl -fsSL https://raw.githubusercontent.com/mabyko/AgentSkills/main/scripts/install-coding-principles.sh | bash
```

Bash 3.2 이상과 기본 Unix 명령이 필요하며 원격 설치에는 curl도 필요합니다. Python·Node는 선택 사항입니다. Node.js 22.20 이상이 있으면 라이브러리를 포함해 배포한 Skills CLI 검색 선택 화면과 Clack 화면을 사용하므로 실행할 때 npm 설치가 필요하지 않습니다. Node가 없거나 선택형 화면을 다운로드·로드하지 못하면 Bash 화면을 사용합니다.

### 범위와 에이전트 선택

개인 전역·프로젝트 범위를 고르고 Space로 에이전트를 선택한 뒤 지침 경로를 확인하고 적용하세요. 처음에는 개인 전역과 Codex·Claude Code가 선택돼 있습니다. 위아래 방향키로 이동하고 Enter로 진행하며 Esc·Ctrl-C로 취소합니다. Node 화면에서는 검색, 그룹 선택·접기를 지원합니다. q 취소는 Bash 화면에서만 동작합니다.

지침 경로를 확인한 도구만 표시하며 프로젝트 22개, 전역 18개를 지원합니다. PC에 설치돼 있지 않아도 선택할 수 있습니다. Cursor·Junie·Kimi Code CLI·Warp는 프로젝트 범위만 지원합니다. 프로젝트에서는 기본 지침이 `AGENTS.md`인 도구와 별도 파일을 쓰는 도구를 나눠 보여주며 어느 그룹도 강제로 포함하지 않습니다. 같은 파일에는 블록을 한 번만 추가하고 실제 경로는 마지막 요약에서 보여줍니다. [도구별 경로와 적용 조건](docs/coding-principles-install.md#agent-instruction-files)을 참고하세요.

### 옵션·업데이트·제거

이미 내려받은 저장소에서는 다음처럼 실행하세요.

```bash
./scripts/install-coding-principles.sh --help
./scripts/install-coding-principles.sh --scope global --agent codex
./scripts/install-coding-principles.sh --scope project --project-dir /path/to/project
./scripts/install-coding-principles.sh --interactive --scope global --agent codex
./scripts/install-coding-principles.sh uninstall
```

원격 실행에 옵션을 붙이려면 파이프 뒤에 `bash -s --`를 사용합니다.

```bash
curl -fsSL https://raw.githubusercontent.com/mabyko/AgentSkills/main/scripts/install-coding-principles.sh | bash -s -- --scope project --agent codex
```

범위·에이전트·프로젝트 경로를 지정하면 선택 화면을 건너뜁니다. 지정한 값을 화면에서 확인하려면 `--interactive`를 붙이세요. `--project-dir`는 `--scope project`와 함께 써야 하며 생략하면 현재 폴더를 사용합니다. 여러 도구는 `--agent`에 쉼표로 구분하거나 옵션을 반복해 지정합니다. `--agent all`은 해당 범위의 지원 도구 전체를 선택합니다. `--yes`는 기본값을 바로 적용하며, 터미널이 없으면 옵션으로 바꾸지 않는 한 개인 전역에 Codex·Claude Code를 설치합니다.

반복 설치는 관리하는 블록만 갱신합니다. 제거할 때도 설치한 범위·에이전트·프로젝트 경로를 선택하세요. `uninstall`의 선택 화면에서 고를 수 있습니다. 블록 밖의 기존 지침, 파일 권한, 심볼릭 링크는 보존합니다. clone 없이 제거하려면:

```bash
curl -fsSL https://raw.githubusercontent.com/mabyko/AgentSkills/main/scripts/install-coding-principles.sh | bash -s -- uninstall
```

프로젝트 지침 변경을 검토하고 커밋하면 팀원과 공유할 수 있습니다. 적용 후 새 에이전트 세션을 시작하세요. 자세한 내용은 [설치·업데이트·제거 안내](docs/coding-principles-install.md)를 참고하세요.

## 기여

전체 작성 규칙은 [AGENTS.md](AGENTS.md)를 참고하세요. 저장소 루트는 스킬 원본과 플러그인 marketplace이며 설치 가능한 플러그인은 아닙니다.

### 스킬

새 스킬은 원본 경로인 `skills/`에 만듭니다.

```bash
scripts/new-skill.sh my-skill
```

이름은 kebab-case를 사용하세요. 필수 파일인 `SKILL.md`의 YAML frontmatter에는 `name`과 사용 조건을 밝히는 `description`만 넣습니다. 작업 절차는 간결하게 작성하고 두 README의 스킬 목록에 추가하세요.

선택 자료는 UI 메타데이터·의존성용 `agents/openai.yaml`, 상세 안내용 `references/`, 정해진 동작을 실행하는 보조 명령용 `scripts/`, 재사용 파일용 `assets/`에 둡니다. `openai.yaml`의 문자열은 따옴표로 감싸고 기본 프롬프트에 `$my-skill`을 포함하세요. 개별 스킬 폴더에는 README나 설치 문서를 추가하지 않습니다.

### 훅과 설치 화면

공통 훅은 `scripts/hooks/`에서, 훅 등록 목록은 `scripts/build-plugin-bundles.py`에서 수정한 뒤 독립적으로 설치 가능한 플러그인 배포본을 갱신하세요.

```bash
python3 scripts/build-plugin-bundles.py
```

작성 환경에는 Python 3.9 이상이 필요합니다. 훅 스크립트의 실행 권한을 유지하고, 내용이 바뀐 플러그인은 두 호스트 manifest의 버전을 동일하게 올리세요. 스킬만 바뀌면 플러그인 버전을 올릴 필요가 없습니다.

선택형 Node 화면은 `scripts/coding-principles-ui.mjs`를 수정한 뒤 Node.js 22.20 이상과 npm으로 다시 빌드합니다.

```bash
npm ci --ignore-scripts
npm run build:coding-principles-ui
```

`scripts/vendor/skills-search-multiselect.ts`의 고정된 Skills CLI 원본과 MIT 라이선스를 유지하세요. 이 파일의 수정 범위는 터미널 입출력과 취소 처리로 제한합니다.

### 검증과 저장소 구조

PR을 열기 전에 실행하세요.

```bash
scripts/validate-skills.sh
python3 -B -m unittest discover -s tests
```

CI는 Node 화면도 다시 빌드해 배포본이 오래됐으면 실패합니다. 검증은 스킬 메타데이터, README 스킬 목록, 플러그인 배포본, 호스트별 버전 일치, 훅 경로·실행 권한을 확인합니다.

```text
skills/<skill-name>/              # 스킬 원본과 선택 자료
scripts/hooks/                   # 훅 원본
plugins/git-hooks/               # 두 호스트용 독립 훅 플러그인
plugins/github-hooks/            # 두 호스트용 독립 훅 플러그인
plugins/apple-dev-hooks/         # 두 호스트용 독립 훅 플러그인
.claude-plugin/marketplace.json   # Claude Code marketplace
.agents/plugins/marketplace.json # Codex marketplace
docs/                            # 코딩 원칙과 상세 안내
scripts/                         # 설치기·생성기·화면·검증
templates/skill/                 # 새 스킬 템플릿
tests/                           # 설치기·훅·패키징 검증
.github/workflows/validate.yml   # CI 검증
AGENTS.md                        # 작성 규칙; CLAUDE.md에서 가져옴
```

## 라이선스

MIT
