# Optional answer-me-with-html adapter

Read this only when considering an installed answer-me-with-html renderer for the selected medium. Use the environment's native tools or custom code when it is unavailable or unsuitable.

## Web and diagrams

The upstream `am` renderer accepts extended Markdown panels and computes the HTML, SVG layout, and themes. Check its installed help for the current syntax, render the draft, inspect the output, and correct reported issues. Keep the draft for panel-level updates.

At reviewed version 0.4.9, UI language support is English, Chinese, and Japanese. Korean text is treated as Chinese for detection and length checks, and `lang: ko` does not provide Korean support. Verify the installed version's language support. For Korean, use a renderer with verified Korean support or generate HTML directly with Korean labels and `lang="ko"`. Preserve natural Korean when a lint rule assumes another language.

## Video

An installed video renderer's draft-to-scenes workflow may supply a player and video export. Check its actual export capabilities and language support before choosing it; use another available workflow for unsupported visuals or output requirements. Deliver and verify the stage requested by the user.

The renderer is optional. Its component set should not limit the requested explanation, and its performance measurements do not describe a different implementation. See [sources and attribution](sources.md) for the reviewed revision and license notices.
