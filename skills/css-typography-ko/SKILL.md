---
name: css-typography-ko
description: Improve Korean web UI readability with CSS typography when designing, implementing, or reviewing Korean text, awkward line breaks, text hierarchy, spacing, or overflow. Use for Korean prose and mixed Korean/Latin interfaces; prose rewriting and native app typography are outside this skill's scope.
---

# Korean CSS Typography

Make Korean text comfortable to read and easy to scan across screen sizes. Treat font choice, hierarchy, spacing, line length, and wrapping as one design decision, grounded in the actual content and existing visual identity. The primary outcome is readable text and reliable text layout; account for rendering cost when selecting enhancements.

## Establish the reading context

- Identify the requested mode: design advice, implementation, or review. Implement when requested; report findings when reviewing.
- Inspect the affected components, typography tokens, font loading, language markup, and supported browsers. Reuse these conventions; add a shared token or utility only when the same decision recurs.
- Distinguish reading-heavy prose, scanning-heavy lists or tables, display headings, controls, and user-authored content. Establish the reader's task before changing density.
- Use real Korean copy, including mixed Latin text and numbers. Derive samples from the product; use the reference samples only when content is unavailable.

## Make typography decisions

Work through the relevant decisions below. Read [CSS decisions and examples](references/css-decisions.md) when choosing values or resolving a specific rendering issue.

For wrapping issues, resolve four separate choices: `word-break` sets ordinary break opportunities, `overflow-wrap` allows emergency breaks, `white-space` controls whitespace preservation and wrapping mode, and `text-wrap` chooses the wrapping mode and composition style. Use `keep-all` as a starting point for Korean prose, `balance` for short headings, and `pretty` selectively for body copy. Preserve authored whitespace by its role, and choose `nowrap` only when the full label can fit. Evaluate these choices together with container sizing.

- **Glyphs and weight:** Confirm that the rendered font covers Hangul and that Korean, Latin, digits, and punctuation look coherent together. Check the fallback and available weights before replacing a font or increasing weight.
- **Hierarchy:** Define heading, body, label, and supporting-text roles using the existing scale. Combine size, weight, spacing, and placement; keep supporting text legible and distinguish links without relying solely on color.
- **Reading rhythm:** Tune font size, unitless line height, paragraph spacing, and text-column width together. Begin with normal tracking and adjust only after seeing the chosen Hangul font. Treat numerical starting points as heuristics, not accessibility requirements.
- **Line composition:** Prefer Korean eojeol (어절, space-delimited units) boundaries for prose when the container permits. Allow emergency breaks for an oversized unbroken string. Judge the rendered composition rather than expecting semantic phrase analysis or guaranteed removal of a short final line.
- **Density and content preservation:** Let controls and containers accommodate their labels. Preserve authored line breaks where they convey structure. Choose truncation only when the reader can retrieve the full content, especially for errors and instructions.

For each change, connect an observed or anticipated reading problem to the chosen adjustment. Keep established brand choices unless evidence shows they impair the requested task.

## Apply CSS in context

- Scope rules to the affected roles and language. Use accurate `lang` markup and `:lang(ko)` where appropriate; Korean defaults are not a blanket policy for every CJK language.
- Use the project's CSS, modules, utilities, or tokens. Preserve code blocks, editors, other locales, and intentional single-line or preformatted components.
- Resolve container constraints before hiding overflow: inspect flex/grid minimum sizing, available width, fixed heights, and padding. Smaller text is not the default fix for a crowded control.
- Add `balance`, `pretty`, or font-relative units as enhancements with a usable baseline. Verify version-specific behavior against current official documentation when it affects the supported browser target.
- Preserve wording and meaningful breaks. If readability requires editing copy or changing the layout beyond the request, explain the tradeoff and stay within the authorized scope.

## Verify the rendered result

When a runnable page and browser tools are available, compare the affected components before and after using the same content and viewport. Use the environment's authorized browser tools; this skill requires no particular browser product.

Check representative narrow and wide layouts, including a 320 CSS-pixel viewport for ordinary flowing content, and enlarged text/zoom. Exercise long Korean terms, Latin identifiers or URLs, numbers with units, multiline labels, and authored line breaks as relevant. For font changes, compare loading/fallback and loaded states on the available target platforms.

Inspect computed styles and the rendered font when inherited rules or mixed glyphs are involved. Confirm no unintended clipping, overlap, horizontal scrolling, inaccessible truncation, or loss of content. Check text contrast and user spacing overrides for affected text; use the reference's accessibility criteria without claiming a full accessibility audit.

If runtime verification is unavailable, inspect the code and specify what still needs browser verification. Proposed CSS and a screenshot alone do not establish cross-browser behavior.

## Deliver

Provide the requested design recommendation, scoped code change, or review findings. Briefly explain the reading problem, the decision, and the validation performed. State material unverified browser/font cases and remaining tradeoffs. An implementation is complete when the affected roles are updated and available checks pass; a review is complete when actionable findings identify the affected role or selector and its reading impact.
