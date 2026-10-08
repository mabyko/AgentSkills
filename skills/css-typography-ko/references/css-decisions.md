# CSS decisions for Korean typography

Consult the section relevant to the observed problem. Examples are starting points to adapt to existing roles and tokens, not a stylesheet to install globally.

## Basis in the original discussion

The [original post](https://www.threads.com/@ddal_kkak_/post/DeLA4z6E3jC), its comparison image, and the author's follow-ups frame Korean wrapping as a readability and design detail. Their practical recommendations are:

- [Word boundaries](https://www.threads.com/@ddal_kkak_/post/DeLA4rzk5ya): start with `word-break: keep-all` for Korean eojeol boundaries.
- [Line composition](https://www.threads.com/@ddal_kkak_/post/DeLA4wzE_LB): use `balance` for short headings and consider `pretty` for body copy with a very short last line.
- [Whitespace](https://www.threads.com/@ddal_kkak_/post/DeLA4xZk64J): use `nowrap` for suitable labels, `pre-line` for authored newlines, and `pre-wrap` when spaces also matter.
- [Emergency wrapping](https://www.threads.com/@ddal_kkak_/post/DeLA4uuky6j): handle terms longer than the container with `overflow-wrap`; the author leaves the distinction between `break-word` and `anywhere` open.

The following sections verify those property semantics and add font, hierarchy, spacing, container sizing, and accessibility guidance. The comparison image is illustrative; actual breaks depend on content, width, font, and browser. Numerical design heuristics below are authored starting points, not standardized Korean typography requirements.

## Fonts, language, and hierarchy

Use the existing brand font when its Hangul coverage and available weights fit the task. A declared family does not establish which font rendered each glyph: fallback can happen per character. Inspect Hangul, Latin, digits, punctuation, and their relative size and baseline. Font replacement can change line breaks and control dimensions; compare fallback and loaded states.

When no brand font is specified, a system stack is a reasonable baseline:

```css
.reading-surface {
  font-family: system-ui, sans-serif;
}
```

This delegates font choice to the platform; it does not promise identical typography across operating systems. Use a named Korean font only when the project provides it or adding it is within scope. Confirm actual font files/weights instead of assuming a requested `font-weight` is available.

Set `lang="ko"` on a Korean page or content subtree and mark other-language passages accurately. `:lang(ko)` matches the resolved language, including inheritance and tags such as `ko-KR`; `[lang="ko"]` only matches that exact attribute on an element.

Make heading levels reflect document structure. Use CSS roles to express visual prominence separately. For scanning surfaces, distinguish the primary label, value, and supporting context with a small coherent set of styles. For prose, separate sections through headings and paragraph spacing. Check that secondary-text colors retain adequate contrast in each affected theme.

Inspect native control styles too: buttons and inputs may use a different font from surrounding copy. Apply the relevant typography tokens or targeted inheritance when that inconsistency is unintended; `font: inherit` also inherits size, weight, and line height, so check the control dimensions afterward.

## Rhythm, measure, and tracking

If the project lacks a scale, ordinary reading copy near `1rem` with unitless line height around `1.6–1.8` is a useful first experiment; multiline headings often need roughly `1.2–1.4`. These ranges are design heuristics. Dense tables, small captions, large display type, and individual font metrics need separate judgment.

Prefer relative font sizes and unitless line height so enlarged text and child sizes scale predictably. Pure viewport-based font sizing can undermine enlargement; if using fluid type, verify its bounds and zoom behavior. Let the container height grow with the resulting lines.

Tune the text-column width with actual Korean paragraphs. `ch` measures the advance of the Latin digit `0`, so `60ch` is not 60 Hangul syllables. `ic` measures the CJK glyph `水`, which is a useful approximation for CJK measure, not an exact Korean character count. Keep a fallback when using it:

```css
.reading-column {
  max-inline-size: 38rem;
}

@supports (max-inline-size: 1ic) {
  .reading-column:lang(ko) {
    max-inline-size: 34ic;
  }
}
```

Choose the final measure by reading several rendered lines at the intended size, not by copying English character-count advice. Use a fluid containing layout with adequate side padding on narrow screens.

Begin with `letter-spacing: normal`. Strong negative tracking compresses already dense Hangul strokes; generous Latin display tracking can fragment Korean words. Apply any adjustment to the specific font and role, and examine mixed text and punctuation. Avoid fixing a width problem by tightening every text style.

## Line composition and overflow

For wrapping Korean prose, a typical scoped baseline is:

```css
.ko-copy:lang(ko) {
  word-break: keep-all;
  overflow-wrap: anywhere;
}

.ko-heading:lang(ko) {
  word-break: keep-all;
  overflow-wrap: anywhere;
  text-wrap: balance;
}
```

`keep-all` suppresses ordinary breaks within CJK words; `anywhere` permits an emergency break when an unbroken string cannot fit. The pair favors eojeol boundaries while retaining an escape for narrow containers. Decide whether that tradeoff suits the role; a narrow data cell may need more permissive wrapping.

`overflow-wrap: anywhere` includes its added break opportunities in min-content sizing; `overflow-wrap: break-word` does not. In flex/grid, inspect the containing item's minimum size and track sizing as well. Apply `min-inline-size: 0` to a relevant item or `minmax(0, 1fr)` to a relevant track when its sizing constraint is the cause, rather than adding them to every layout.

`word-break: break-all` can fragment words even when moving the whole word to a new line would work. Reserve aggressive breaks for content that calls for them. Deprecated `word-break: break-word` and valid `overflow-wrap: break-word` are distinct declarations.

`balance` aims for similar line lengths in short blocks, with browser-specific line-count limits. `pretty` favors improved composition over the fastest wrapping and can help with short final lines. Neither guarantees meaningful phrase boundaries or a particular final line. Consider `pretty` selectively for reading copy; check support, actual Korean output, and rendering cost for the target content. Unsupported values should leave a readable default wrap.

Compose optional body styling without changing an existing wrapping mode:

```css
@supports (text-wrap-style: pretty) {
  .ko-copy:lang(ko) {
    text-wrap-style: pretty;
  }
}
```

`text-wrap-style` only chooses among available soft-break opportunities and has no wrapping effect when the mode is `nowrap`. `keep-all` can matter more than `pretty` for Korean composition because it changes those opportunities. Support for a value establishes syntax acceptance, not identical layout across browsers. For continuously edited `contenteditable` text, consider `stable` when reflow above the caret disrupts editing, instead of balancing the entire editable block.

If composing an intentional brand headline, retain meaningful editorial breaks when requested and verify every breakpoint. Ordinary responsive prose should not accumulate fixed `<br>` tags to repair one screenshot.

## Controls, authored whitespace, and truncation

Use `white-space: normal` for ordinary wrapping text; use `pre-line` to preserve authored newlines while collapsing repeated spaces, or `pre-wrap` when both newlines and spaces are meaningful. Code and structured preformatted data have their own policy.

These properties interact: `white-space` is a shorthand that includes wrapping mode, and `text-wrap` also sets that mode. Keep declarations and inheritance consistent; a later `text-wrap: balance` can enable wrapping where `white-space: nowrap` previously disabled it.

For user-authored content with meaningful line breaks, scope the policy separately from ordinary prose:

```css
.ko-user-content:lang(ko) {
  white-space: pre-wrap;
  word-break: keep-all;
  overflow-wrap: anywhere;
}
```

Use `pre-line` instead when repeated spaces should collapse. Render user content through the framework's normal text/escaping mechanism; whitespace styling does not require inserting untrusted HTML.

Apply `nowrap` to labels only when the available width accommodates the full label at the tested font size. For crowded controls, consider wrapping, padding, or available width before reducing text size. Verify fixed-height controls with multiline labels and user spacing changes.

Single-line ellipsis needs a constrained width, hidden overflow, and nonwrapping text. Treat ellipsis and line clamping as product choices, not generic overflow repairs. Give users a keyboard/touch-accessible way to retrieve the full value where needed; critical instructions and error messages should stay readable in context. Hover-only disclosure is insufficient for these uses.

## Focused verification

Use product copy first. If it is unavailable, these samples expose distinct failure modes:

- Short heading: `필요한 정보를 한눈에 확인하고 다음 작업을 시작하세요.`
- Korean prose: `선택한 항목은 저장 후에도 수정할 수 있습니다. 변경한 내용이 목록에 반영되는지 확인해 주세요.`
- Unbroken term: `개인정보처리방침변경이력확인`
- Mixed text: `API 응답 시간 120ms · 월 19,900원 · v2.3 업데이트`
- Long identifier or URL: `customerSubscriptionCancellationRequested`, `https://example.com/account/subscriptions/2026/changes`
- Authored content: `첫 번째 줄\n두 번째 줄  공백 유지` (replace `\n` with an actual newline).

Check the affected role at the application's narrowest supported size and a typical desktop width. For ordinary flowing content, include 320 CSS pixels; data tables or other essential two-dimensional layouts need a separate overflow decision. Check 200% text enlargement and a zoom/reflow case; use actual zoom or equivalent viewport conditions and report which was tested.

WCAG AA text contrast is generally at least 4.5:1, or 3:1 for large text (at least 18pt, or 14pt bold), subject to the criterion's exceptions. Evaluate the actual color pair and size/weight, including muted text and themes; semantic role names do not establish contrast.

For user text-spacing overrides, test applicable text with line height `1.5`, paragraph spacing `2em`, letter spacing `0.12em`, and word spacing `0.16em` together. Confirm no content/functionality is lost. These are resilience test conditions, not a required default design. Check the override actually wins in computed styles, then remove temporary test styles.

Record the browser, viewport/enlargement condition, representative content, and any untested font/platform behavior. A focused typography check does not establish whole-page WCAG conformance.

## Sources

For property semantics and accessibility criteria, consult:

- MDN: [font-family](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/font-family), [:lang()](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Selectors/:lang), [line-height](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/line-height), [length units](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/length).
- MDN: [word-break](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/word-break), [overflow-wrap](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/overflow-wrap), [text-wrap](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/text-wrap), [text-wrap-style](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/text-wrap-style), [white-space](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/white-space).
- W3C: [Contrast (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html), [Resize Text](https://www.w3.org/WAI/WCAG22/Understanding/resize-text.html), [Reflow](https://www.w3.org/WAI/WCAG22/Understanding/reflow.html), [Text Spacing](https://www.w3.org/WAI/WCAG22/Understanding/text-spacing.html).
