---
name: break-it-down
description: Explain a difficult concept, system, or result by making its mechanism and limits understandable. Use for "break this down", "쉽게 설명해줘", or a visual, interactive, or narrated explanation of how something works.
---

# Break It Down

Design an explanation around the reader's missing understanding. The result should let them reason through a case, follow a derivation, or make the requested distinction themselves.

## Find the question

Use the current topic when none is supplied. Identify the reader's question and the knowledge they need to answer it. For an unfamiliar system, this might be how parts cooperate; for a decision, why one case succeeds and another fails. A manual may need both an introduction to the model and a direct route to a specific task.

Honor the requested audience, medium, depth, and stage. A script, a source file, and a finished artifact are different deliverables. For a narrow edit, change only the requested part. Infer the rest from context; ask only for information that changes the explanation.

## Build the model from evidence

Read the supplied material or inspect the relevant implementation. Extract the parts, relationships, transformations, and conditions that answer the question. Keep distinctions that change the result: actors, states, AND/OR conditions, thresholds, exceptions, obligations, and uncertainty. Separate verified behavior from proposals, assumptions, and illustrative examples.

Choose a concrete case that exposes the mechanism when the question needs one. Work through its intermediate steps. If a boundary or common misconception matters, choose a nearby contrasting case and identify the condition that changes the outcome. A definition-only request need not become a simulation.

## Choose what carries the explanation

Decide how the reader will follow the model before designing the page or scenes:

- A verbal derivation connects each claim to its reason or evidence.
- A diagram makes relationships visible through position, connection, direction, or scale.
- An interactive model lets the reader change an input or state and inspect the resulting process and outcome.
- An animated explanation develops an idea through coordinated visual changes and, when useful, narration.

Use the requested medium. When the choice is open, choose for the understanding it enables. A bespoke, disposable page or video is worthwhile when it reveals something that remains difficult in prose. Combine representations when they explain different aspects of the same model.

Let that representation organize the explanation. Give necessary terms and instructions near the objects or actions they explain, and make supporting details reachable without interrupting the main reasoning. Match the structure to the subject and task; a relationship map, worked calculation, procedural walkthrough, and reference manual need different arrangements.

For a full rebuild, derive the organization from the question and source facts afresh. Treat the previous artifact as evidence and a record of constraints, then decide which of its content and implementation genuinely serve the new explanation. Visual novelty alone is not evidence of improvement.

## Produce and check

Apply [language guidance](references/language.md) to prose, labels, controls, captions, and narration. Follow the explicit output language, then known user preference, then the request's language; quoted source language does not override it.

For diagrams, interactive HTML, or video, read the relevant section of [artifact delivery](references/artifacts.md) before production. Use available tools and the requested surface. Preserve editable source for file deliverables.

Check two things separately:

1. **Reasoning:** Trace the chosen case through the delivered explanation. Can the reader find the intermediate relationships and the condition responsible for the result? Check a relevant exception or contrast, and compare claims with the evidence. Keep mandatory conditions visible at the step where they matter.
2. **Execution:** Check the actual requested deliverable: rendered labels, working interactions, or video playback. For a script or source-only request, verify that stage and label unmeasured timing or untested rendering accordingly.

Deliver the explanation with only the usage notes and verification limits the reader needs. Describe any partial artifact accurately when a required capability is unavailable. A successful render establishes execution, not factual correctness or measured learning.
