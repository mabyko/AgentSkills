# Sources and adaptation

This skill is an unofficial synthesis of three sources. It is not affiliated with or endorsed by Andrej Karpathy or either project.

- [Karpathy's post](https://x.com/karpathy/status/2105819303471976479), October 2, 2026: as models take on more work, human work increasingly involves understanding and oversight. Explore controlled writing, diagrams/images, interactive HTML, and bespoke explainer videos to help with that task. He repeatedly presents the next medium as potentially better and expresses the most enthusiasm for custom videos, including a 3Blue1Brown-style example with speech synthesis or local alternatives. He encourages large, custom, disposable artifacts that previously would not have justified their production cost. His “80%” suggestion relaxes a stringent writing standard; it is not a measurable compliance score.
- [answer-me-with-html](https://github.com/QingYunA/answer-me-with-html/tree/8653e0f04bb65a7b73510d44e86bf41688d71a5c): separate content drafts from rendering; select components by information shape; answer one sub-question per panel; retain editable source; revise the affected panel; build narrated videos from scenes and beats. Reviewed version: 0.4.9.
- [kar-plain](https://github.com/Burntgogi/kar-plain/tree/9e3f063a44b8cc94723f2617dd2a22f5ecb5d246): select a suitable medium and output language; preserve conditions, negation, quantities, obligations, and uncertainty; distinguish examples from source facts; verify the actual deliverable for each medium.

The projects make different implementation choices: answer-me-with-html includes a renderer and can activate proactively; kar-plain installs two instruction files and uses explicit invocation. Combining their ideas does not imply identical defaults, output, or performance.

## What this skill adds

Karpathy offers a direction and examples, not a complete format-selection algorithm or an empirical ranking for all tasks. His post does not mandate a smallest-artifact rule, a concept-count threshold, a fixed panel catalog, a bundled CLI, or a requirement to always make a video. Keep the invitation to explore rich, bespoke output without attributing those implementation rules to him.

`explain` adds practical defaults: use the current conversation when no topic is supplied, accept ordinary-language format choices, preserve the reader's language and source meaning, use the available tools, and verify the delivered result. Korean writing guidance, accessibility checks, editable source, downloadable-video defaults, and authorization boundaries are implementation choices, not claims from the post. Automatic discovery remains enabled; invocation does not require a slash-command parser.

The entrypoint contains the shared workflow. Production details are loaded by medium. The skill does not vendor either project's renderer, require their installation, or reproduce their settings/update/cleanup features. Existing renderers are optional production tools, and custom code remains available for an explanation that needs it.

## Evidence boundaries

- [answer-me-with-html's benchmarks](https://github.com/QingYunA/answer-me-with-html/blob/8653e0f04bb65a7b73510d44e86bf41688d71a5c/bench/README.md) measure particular models, topics, and environments. Fewer generated HTML tokens do not establish lower total cost or better comprehension.
- [kar-plain's prose comparison](https://github.com/Burntgogi/kar-plain/blob/9e3f063a44b8cc94723f2617dd2a22f5ecb5d246/docs/prose-comparison.txt) is an agent assessment of a small set of Korean and English examples, not a human comprehension study.
- [ASD-STE100](https://www.asd-ste100.org/) is an English technical-writing specification. This skill uses its clarity principles and does not bundle its dictionary or certify compliance.

## Attribution

The adapted instructions retain the notices of both MIT-licensed projects below. Karpathy's post and the ASD-STE100 specification remain external references; the projects' MIT licenses do not apply to them.

Copyright (c) 2026 Answer me with HTML contributors

Copyright (c) 2026 Burntgogi

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
