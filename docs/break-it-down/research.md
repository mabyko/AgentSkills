# break-it-down 조사와 설계 결정

조사일: 2026-10-27. Codex와 Claude Opus 5.5(effort=max, Claude-dev-max)가 역할을 나눠 공개 자료를 조사했다. 카파시의 제안, 공식 표준, 커뮤니티의 구현을 같은 권위의 규칙으로 취급하지 않았다.

## 조사 범위

X 원글과 첫 답글 페이지의 미러, Threads 본문과 첨부, 공개 검색에서 찾은 **22개 저장소의 스킬 엔트리포인트 및 관련 부분**을 확인했다. 아래는 실제 확인한 커밋에 고정한 링크다. ChangWenC의 별도 중국어 스킬도 읽었다. 모든 코드·참조·평가를 실행하거나 인터넷의 모든 구현을 조사했다는 뜻은 아니다.

검색은 `ASD-STE100`, `ASD-STE100 korean`, `STE 한국어`, `karpathy STE skill`, `항공정비`와 X·Threads·GitHub 도메인별 조합으로 진행했다. Claude는 GitHub 검색 결과 357건 중 별 순 상위 40개를 선별했다고 보고했고, 작성자는 추가 검색에서 매체·다국어·린터 구현을 찾아 원문을 대조했다. 그중 실제 스킬 지침이나 직접 관련된 구현을 확인한 22개를 아래에 기록했으며, 목록만 확인한 결과를 모두 포함하지 않았다. 인기 수치는 품질 판정에 사용하지 않았다.

X 직접 접근은 도구별 402/403으로 막혀 [본문을 재현한 미러](https://xitter.cf/karpathy/status/2105819303471976479)를 사용했다. X 전체 인용글·검색·답글과 Threads 전체 답글을 확인하지 못했다. [Threads 본문](https://www.threads.com/@leo_lazybuilder/post/De3cq4VnV9D)과 첨부는 앞선 실행에서 직접 확인했다. 공식 사이트는 웹 도구가 차단됐지만 직접 내려받은 공식 PDF로 관련 규칙을 읽었다. 비공개 세션이나 계정은 사용하지 않았다.

## 세 출처가 실제로 말하는 것

- **공식 ASD-STE100:** ASD/STEMG가 관리하는 영어 기술문서 표준이며 쓰기 규칙과 사전으로 구성된다. 카파시가 만든 표준이 아니다. [공식 소개](https://www.asd-ste100.org/about_STE.html), [공식 FAQ](https://www.asd-ste100.org/STE_faq.html)
- **카파시:** LLM 출력의 이해 부담을 줄이기 위해 STE를 느슨하게 활용하고, 다이어그램·인터랙티브 HTML·맞춤 설명 영상을 시도하라고 제안했다. 글→그림→HTML→영상을 점점 더 나은 형식으로 소개했고, 맞춤 영상을 가장 유망하게 보았다. 구체적인 80% 규칙표나 역할별 보고 틀을 정의하지 않았다. [X 원글](https://x.com/karpathy/status/2105819303471976479), [확인한 미러](https://xitter.cf/karpathy/status/2105819303471976479)
- **Threads와 업무 글 스킬:** 결론을 앞에 두고 주체·일정·행동별로 정보를 정리하는 실용적 적용이다. 이런 구성을 모든 주제에 강제하거나 STE의 필수 서식으로 부를 근거는 없다.

## 공식 규칙 대조

[Issue 9 공식 PDF](https://www.asd-ste100.org/assets/files/ASD-STE100_ISSUE9.pdf)의 관련 페이지를 읽었다. 6.1과 6.5는 렌더링한 페이지도 확인했다. 전체 434쪽의 모든 규칙과 사전을 감사한 결과는 아니다.

| 규칙 | 공식 내용의 요지 | 이번 설계에 반영한 점 |
|---|---|---|
| 3.6, 페이지 1-3-5~6 | 능동문을 쓰되 설명문에서 수행자가 불명일 때만 수동문을 허용 | 능동문을 만들려고 수행자를 지어내지 않음 |
| 5.1~5.4, 페이지 1-5-1 이후 | 절차 문장 길이, 동시 동작 예외, 명령문, 필요한 조건의 선행 | 동작 분리 때문에 동시성을 바꾸지 않고 조건을 동작 옆에 유지 |
| 6.1~6.2, 페이지 1-6-1~4 | 정보를 점진적으로 주고 핵심어·연결어로 관계를 드러냄 | 답과 최소 배경 뒤에 근거·중간 상태를 논리적으로 연결 |
| 6.3~6.6, 페이지 1-6-4~7 | 설명문 길이, 관련 정보의 문단화, 주제문, 문단당 한 주제 | 주제문으로 시작하는 문단과 질문에 맞는 묶음; 한국어에 영어 단어 수를 강제하지 않음 |
| 9.1, 페이지 1-9-1~2 | 단순 치환이 의미를 바꾸면 문장 구조를 바꿈 | 추정·권고·조건의 강도와 범위를 지키며 재작성 |

단락의 주제문을 먼저 쓰는 것은 표준에 있다. 모든 답변 첫 문장을 최종 결론으로 고정하는 것은 별도의 업무 글쓰기 선택이다. 이번 스킬은 답 먼저를 기본으로 삼되, 답을 이해하는 데 꼭 필요한 배경은 짧게 먼저 제시할 수 있게 했다.

## 공개 구현 비교

| 구현 | 주된 목적 | 채택·제외 판단 |
|---|---|---|
| [danyuchn/asd-ste100-skill](https://github.com/danyuchn/asd-ste100-skill/blob/8da6b6340aa22faf46fd07db8efbdea010cd38d9/SKILL.md) | 에이전트가 읽는 영어 재작성 | 의미·양태·리터럴 보존을 채택. 인간 설명의 전체 흐름과 매체 선택은 별도로 설계. |
| [prithivrajmu/asd-ste100](https://github.com/prithivrajmu/asd-ste100/blob/d93237679681a74873bdee4f1a7869f728968dbd/SKILL.md) | 실용적인 STE 설명과 매체 | 재작성·요약·설명 구분, 명시적 준수 확인을 참고. HTML·영상의 요청 전용 정책은 그대로 옮기지 않음. |
| [nuelcyoung/asd-ste100](https://github.com/nuelcyoung/asd-ste100/blob/ee9aad84c24f1d3a0c118c264a123a0ad06de3bf/SKILL.md) | 공식 준수 지향 기술문서 | 의미 우선과 사전의 품사·의미 확인을 참고. 규칙 번호와 치환 예시는 공식 원문으로 재확인. |
| [0xpili/simplified-technical-english](https://github.com/0xpili/simplified-technical-english/blob/1e148d670cba46685ad2b4c3f2354a637a7fdbbe/SKILL.md) | 기술문서·단어 목록 | 절차와 설명 구분을 참고. 단어 목록은 번들하지 않고 공식 표준으로 확인. |
| [clayleopardlabs/ste100-skill](https://github.com/clayleopardlabs/ste100-skill/blob/40d8707db3fb2549742a8be5f042672723f4b540/SKILL.md) | Issue 8 기반의 오래된 구현 | 기계 검사와 의미 검사를 구분할 필요를 확인. 사전 치환과 린터 결과를 절대 기준으로 삼지 않음. |
| [ninajingit/ste-business-writing](https://github.com/ninajingit/ste-business-writing/blob/acf472584adcf9114ed085383a3ed267b69357a3/SKILL.md) | 업무 글 재작성 | 결론 우선과 불필요한 재작성 자제를 채택. 모든 답변의 전후 비교표와 양태를 바꾸는 치환은 제외. |
| [ryanrudd/skills](https://github.com/ryanrudd/skills/blob/4a0c674424fd693df3768010ba82c396560fb184/skills/asd-ste100/SKILL.md) | 대화 밖 독자를 위한 기술문서 | 대화 내부 별명·발견 과정을 독자 맥락으로 바꾸는 점을 참고. 불확실성의 일괄 삭제는 제외. |
| [Jamfin92/skills](https://github.com/Jamfin92/skills/blob/24314eaa5bc63db860f9ec4f41e9f179cfd1e9d4/ste/SKILL.md) | 소프트웨어 문서용 실용 STE | 단어 수를 목표로 다루는 접근을 참고. 가설을 확정 원인으로 바꾸는 예시는 채택하지 않음. |
| [AminBlg/SimpleEnglish](https://github.com/AminBlg/SimpleEnglish/blob/a6fcb4fde098b33617cc1578d151ebf58774b883/skills/simple-english/SKILL.md) | 문서와 지속적인 채팅 문체 | 질문에 직접 답하는 기본 흐름을 참고. 서식 금지와 양태 치환, 예시의 사실 추가는 제외. |
| [say8425/SimpleKorean](https://github.com/say8425/SimpleKorean/blob/4ba6a6361a28805407412408534fa3456fa0f555/skills/simple-korean/SKILL.md) | 한국어 문서와 채팅 문체 | 자연스러운 한국어와 직접 동사를 참고. 영어 규칙의 기계적 이식과 고정 서식 정책은 제외. |
| [beamonic/ste-ko](https://github.com/beamonic/ste-ko/blob/ed98bcb249c6a5b129e983a5df8a761b520e0bb3/skills/ste-ko/SKILL.md) | 한국어 업무 글·결과 보고 | 상태와 검증 범위를 구분하는 점을 참고. 25어절 상한·항상 다음 행동으로 끝내기는 제외. |
| [dualface/ste-zh](https://github.com/dualface/ste-zh/blob/27d57e4d6609ce88e14dd15cbae355223a83b246/SKILL.md) | 중국어 작업 결과·결정 보고 | 현재 상태와 판단 조건을 명시하는 점을 참고. 고정 상태어와 필수 출력 틀은 제외. |
| [lemonhall/asd-ste100-skill-zh](https://github.com/lemonhall/asd-ste100-skill-zh/blob/01345c50d240ab5f5ee34c95702adb6078a70f1b/SKILL.md) | 중국어 재작성·린터 | 정식 영어 준수와 언어별 적용을 나누고 양태를 보존하는 점을 참고. 중국어 글자 수 규칙은 옮기지 않음. |
| [lenML/stcn100](https://github.com/lenML/stcn100/blob/4cfdba0dd69590d52a1026afda5aa1dcf04b2888/skill/SKILL.md) | 중국어의 프로그램 검사 | 결정적 검사·휴리스틱·의미 판단을 구분하는 점을 참고. 한국어를 위한 새 린터는 만들지 않음. |
| [FutureAtoms/karpathy-ladder](https://github.com/FutureAtoms/karpathy-ladder/blob/07c70890b2fbd96eaf757fb103908c46623897b4/skills/legible-explainer/SKILL.md) | 사양서 형태의 설명과 완성 영상 | 답 먼저, 각 패널이 질문을 해결하는 구성, 실제 렌더링 검사를 참고. 고정 공학 도면 미관과 긴 기본 분량은 제외. |
| [JordanBelfort1/explaining-in-asd-ste100](https://github.com/JordanBelfort1/explaining-in-asd-ste100/blob/1f9ebb2a2933ec6dcf7d29d39e6942c8a4d14694/SKILL.md) | 매체 자동 상향과 폴란드어 설명 | 이해 실패 시 표현을 바꾸는 점을 참고. 무조건 상위 매체·세션 지속·고정 세 부분 응답은 제외. |
| [bowen31337/comprehension-ladder](https://github.com/bowen31337/comprehension-ladder/blob/1bc443f155ed48de555673aa282c1f61f298049e/SKILL.md) | 의미를 공유하는 다중 매체 | 표현을 바꿔도 가설·수치·관계가 같아야 한다는 점을 채택. 임의 백분율 모드와 다음 단계 홍보는 제외. |
| [ChangWenC/understanding-ladder](https://github.com/ChangWenC/understanding-ladder/blob/27b0957818f57a9c1d0ecdde1f50c2e3752f972c/skills/understanding-ladder/SKILL.md) | 영어·중국어 형식 선택 | 핵심 어려움에 맞춘 형식 선택과 중국어 별도 지침을 참고. 모든 출력의 확인 과제와 영상 대신 대본으로 완료하는 정책은 제외. |
| [duolahypercho/explain-ladder](https://github.com/duolahypercho/explain-ladder/blob/ead4d74f5273defec413538a4c3099b9831dbbf2/explain-ladder/SKILL.md) | 형식·독자 질문과 영상 파이프라인 | 하나의 설명 모델을 여러 매체로 옮기는 점을 참고. 매번 형식을 묻는 절차와 고정 영상 길이는 제외. |
| [bounce12340/karpathy-explain-skill](https://github.com/bounce12340/karpathy-explain-skill/blob/183ff2db8b4616df061a90068ad07127b5a1986f/skills/karpathy-explain/SKILL.md) | 공학 설명의 증거·사례·깊이 | 근거를 보존한 단계별 설명과 작은 수정의 범위 유지를 참고. 모든 주장에 상태 태그·고정 30초/3분 양식은 제외. |
| [JAICHANGPARK/ASD-STE100](https://github.com/JAICHANGPARK/ASD-STE100/blob/2af2011224de38df2baee6af22e2bfed306a12ca/skills/asd-ste100/SKILL.md) | 엄격/실용 모드·플러그인·린터 | 절차와 설명을 나누고 매체별 제작 절차를 분리하는 점을 참고. 근거 없는 속도 수치와 임의 수치 추가는 제외. |
| [achinthbharadwaj/speak-ASD-STE100](https://github.com/achinthbharadwaj/speak-ASD-STE100/blob/86f8b9126d76f10d443b9f8a0b9b3a66f14e3a13/skills/speak-ste/SKILL.md) | 세션 전체 STE 문체 | 절차·설명 구분을 참고. 자동 지속·양태 제거·예시에 없는 시간 추가는 제외. |


## 선택한 설계

1. **기본 응답:** 질문에 먼저 답하고 근거·작동 원리·판단을 바꾸는 조건을 연결한다. 완료 상태를 설명할 때는 소스 변경, 검증, 실제 사용 상태를 구별한다.
2. **정보 구조:** 한 문단에 한 주제를 두고, 주제문 뒤에 근거와 세부 사항을 연결한다. 주체·시간·원인·상태·비교 기준은 독자의 질문에 맞춰 선택한다.
3. **의미 보존:** 이번 사건의 가설을 일반 가능성이나 확정 원인으로 바꾸지 않는다. 권고를 의무로 강화하지 않는다. 문단·화살표·제목도 원자료에 없는 책임과 인과를 암시하지 않는다.
4. **매체:** 관계는 그림, 입력에 따른 결과는 인터랙티브 모델, 시간에 따른 변환은 애니메이션으로 드러낸다. 선택한 결과물을 실제로 제작하되 사용자가 요청한 표면과 단계를 지킨다. 모든 형식을 만들거나 매번 다음 형식을 권하지 않는다. 카파시의 상향 순서에서 이해에 필요한 형식을 선택하는 쪽으로 바꾼 설계 판단이다.
5. **지침 규모:** 본문은 기본 동작에 집중하고, 언어별 규칙과 정식 준수 작업은 `language.md`, 제작과 실행 확인은 `artifacts.md`로 나눈다. 새 린터·모드·상태 저장 기능은 추가하지 않는다.

공개 예시에서 발견한 위험은 원문에 없는 원인·수치·수행자를 더하는 것, 이번 사건의 추정을 일반적 가능성으로 바꾸는 것, 권고를 의무로 바꾸는 것이다. 이런 예시는 그대로 가져오지 않았다. 다른 스킬의 점수·속도·절감 주장은 재현하지 않았으므로 이번 스킬의 효과 근거로 사용하지 않는다.

본문·참조는 자체 작성했다. 외부 스킬이나 공식 사전 파일을 그대로 번들하지 않는다. 이 기록은 정식 STE 준수 인증이나 모든 구현의 우열 판정이 아니다.
