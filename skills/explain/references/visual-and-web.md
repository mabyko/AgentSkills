# Diagrams and interactive HTML

## Draft the content first

Write the core answer and the supporting sub-questions before styling. Give each panel one question. Choose a linear reading order for a guided explanation, or an overview layout when the reader needs to compare parts. Split or simplify a crowded view instead of shrinking its labels.

Select representations by the information:

| Information | Useful representation |
| --- | --- |
| Structure, relationships, decisions | Flow graph with labeled edges and branches |
| Messages between actors over time | Sequence diagram |
| Modules, folders, categories | Tree |
| Evolution or phases | Timeline |
| Alternatives across common criteria | Comparison table and a reasoned conclusion |
| Values against a limit | Labeled quantities with units and a visible threshold |
| Changes or misconceptions | Before/after view or an annotated example |

Use real labels and supported values. An arrow must have an interpretable direction and meaning. Label inferred or proposed relationships. Mark illustrative values explicitly.

## Produce a diagram or image

Use Mermaid or SVG when relationships and labels need to be exact and editable. Use an available image-generation workflow when a spatial illustration or visual analogy better explains the idea. Preserve its relevant editable source or generation brief.

Render the result and inspect labels, edge direction, overlaps, contrast, and legibility at the delivered size. Check branches and exceptions against the source; attractive geometry cannot compensate for a missing condition.

## Produce a web explanation

For a standalone deliverable with no specified stack, prefer one self-contained HTML file with inline styles and scripts and local or embedded assets. For inline output, use the host's supported rendering surface. If the user specifies a stack or existing application, work within it.

Separate the explanation's data and content from layout and rendering. Reuse available components or a suitable renderer instead of regenerating repeated styling and calculating diagram coordinates by hand. A renderer's component set should not limit the user's requested experiment: implement the additional interaction when needed.

Make interaction serve learning. Examples include changing a parameter and observing the result, stepping through a protocol, toggling an alternative, or revealing the evidence behind a claim. Theme switching alone does not satisfy a request to explore a model. Label controls, expose units and assumptions, and supply a useful initial state.

Keep the content draft beside the output or embedded as safely escaped text that can be copied back out. On revision, change the affected section and preserve unrelated content and user edits.

Check before delivery:

1. Open the actual output in the available browser or preview tool. Inspect desktop and narrow layouts for clipped text, diagrams, or controls.
2. Exercise the primary interaction, including relevant bounds, invalid input, and reset behavior. Check a known result against the explanation's formula or logic.
3. Check visible controls with keyboard focus and ensure meaning is not conveyed by color alone. Verify runtime errors and missing assets.
4. Confirm labels, document language, and controls match the requested language. For a promised offline file, check that required assets and data are bundled.

## Using answer-me-with-html when already available

The upstream `am` renderer accepts extended Markdown panels and computes the HTML, SVG layout, and themes. Use its installed help for the current syntax, render the draft, inspect the output, and correct reported issues. Keep the draft for panel-level updates.

At reviewed version 0.4.9, UI language support is English, Chinese, and Japanese. Korean text is treated as Chinese for detection and length checks, and `lang: ko` does not provide Korean support. For Korean, use a renderer with verified Korean support or generate the HTML directly with Korean labels and `lang="ko"`. Do not rewrite Korean merely to pass the Chinese lint rules.

This skill does not require that renderer. If it is unavailable, use the same content-first process with the environment's native tools. Do not claim the upstream project's performance measurements for a different implementation.
