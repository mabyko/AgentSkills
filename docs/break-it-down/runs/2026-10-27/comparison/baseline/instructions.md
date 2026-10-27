---
name: break-it-down
description: Explain a difficult concept, system, or result by making its mechanism and limits understandable, with content, order, and grouping chosen for the reader's question. Use for "break this down", "쉽게 설명해줘", or a visual, interactive, or narrated explanation of how something works.
---

# Break It Down

Design an explanation around the reader's missing understanding. Choose the content and its progression as well as the words and medium. The result should let them reason through a case, follow a derivation, or judge what a result establishes.

## Find the question

Use the current topic when none is supplied. Identify the reader's question and what they should be able to predict, distinguish, decide, or do afterward. For an unfamiliar system, this might be how parts cooperate; for a decision, why one case succeeds and another fails. A manual may need both an introduction to the model and a direct route to a specific task.

Honor the requested audience, medium, depth, and stage. A script, a source file, and a finished artifact are different deliverables. For a narrow edit, change only the requested part. Infer the rest from context; ask only for information that changes the explanation.

## Build the model from evidence

Read the supplied material or inspect the relevant implementation. Extract the parts, relationships, transformations, and conditions that answer the question. Keep distinctions that change the result: actors, states, AND/OR conditions, thresholds, exceptions, obligations, and uncertainty. Separate verified behavior from proposals, assumptions, and illustrative examples.

Choose a concrete case that exposes the mechanism when the question needs one. Work through its intermediate steps. If a boundary or common misconception matters, choose a nearby contrasting case and identify the condition that changes the outcome. A definition-only request need not become a simulation.

## Compose the reader's path

Select the facts needed for the reader's question, then decide what they need first and what follows from it; the order of collected material need not be the reading order. Prioritize the answer, its explanation, and conditions that change the reader's judgment. Move incidental history and implementation detail out of the main path unless they explain the result. Simplifying must preserve decisive evidence, uncertainty, and exceptions.

Choose a progression that fits the purpose. These are options, not mandatory outlines:

- For a result or decision, establish the outcome and its scope, then give the evidence, limits, and any required action.
- For a mechanism, give a brief answer or orient the reader to the situation, then trace a concrete case through causes and intermediate changes to explain the rule and where it stops applying.
- For a comparison, establish the shared question and compare alternatives on the same criteria; keep the condition that changes the choice beside the difference.
- For a procedure, put prerequisites before the actions they govern and show the expected result where the reader can check it.

Group related information by the relationship the reader needs to see: actor, time, cause, state, or comparison criterion. Do not let a heading or placement imply an actor, state, or certainty unsupported by the source. Keep an action whose actor the source does not name outside actor groups, or say that the source does not name the actor.

In a work-result explanation, connect who did what with the evidence of completion; distinguish completed work, scheduled checks, and unresolved work. Give a next check or say whether reader action is needed when the evidence and task call for it, even when no action is needed. Role headings help when responsibility is the question; they are not a template for every explanation.

Make each paragraph, diagram region, interaction, or scene answer a coherent question and supply what the next part needs. Use headings and lists when they make groups easier to find; use connected prose for a continuous argument. Shorter sentences alone do not fix missing context, scattered evidence, or an unexplained jump.

## Choose what carries the explanation

Choose how to express that progression before designing the page or scenes:

- A verbal derivation connects each claim to its reason or evidence.
- A diagram makes relationships visible through position, connection, direction, or scale.
- An interactive model lets the reader change an input or state and inspect the resulting process and outcome.
- An animated explanation develops an idea through coordinated visual changes and, when useful, narration.

Use the requested medium. When the choice is open, choose for the understanding it enables. A diagram, interactive page, or video is worthwhile when it reveals a relationship or transformation that remains difficult in prose. Combine representations when they explain different aspects of the same model.

Use the representation to carry and refine the reader's progression. Give necessary terms and instructions near the objects or actions they explain, and make supporting details reachable without interrupting the main reasoning. Match the structure to the subject and task; a relationship map, worked calculation, procedural walkthrough, and reference manual need different arrangements.

For a full rebuild, derive the organization from the question and source facts afresh. Treat the previous artifact as evidence and a record of constraints, then decide which of its content and implementation genuinely serve the new explanation. Visual novelty alone is not evidence of improvement.

## Produce and check

Apply [language guidance](references/language.md) to prose, labels, controls, captions, and narration. Follow the explicit output language, then known user preference, then the request's language; quoted source language does not override it.

For diagrams, interactive HTML, or video, read the relevant section of [artifact delivery](references/artifacts.md) before production. Use available tools and the requested surface. Preserve editable source for file deliverables.

Check three things separately:

1. **Composition:** Read in the delivered order. Does the opening address the reader's question or establish the context needed to answer it? Can they follow each transition without reconstructing scattered facts or encountering unexplained terms? Can they make the intended judgment, including completion and next steps when relevant?
2. **Reasoning:** Trace the chosen case through the delivered explanation. Can the reader find the intermediate relationships and the condition responsible for the result? Check a relevant exception or contrast, and compare claims, including those implied by grouping or placement, with the evidence. Keep mandatory conditions visible at the step where they matter.
3. **Execution:** Check the actual requested deliverable: rendered labels, working interactions, or video playback. For a script or source-only request, verify that stage and label unmeasured timing or untested rendering accordingly.

Deliver the explanation with only the usage notes and verification limits the reader needs. Describe any partial artifact accurately when a required capability is unavailable. A successful render establishes execution, not factual correctness or measured learning.
