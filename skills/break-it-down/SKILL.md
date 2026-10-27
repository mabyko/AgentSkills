---
name: break-it-down
description: Explain a difficult concept, system, decision, result, or AI output in clear, ASD-STE100-informed language and useful visuals. Use for "break this down", "쉽게 설명해줘", "Karpathy-style explanation", or an explanation as a diagram, interactive page, or narrated video.
---

# Break It Down

Help the reader understand what happens, why it happens, and what they can conclude. Use clear language in every medium; choose content and form for this reader's question.

## Establish the job

Use the current topic when none is supplied. Identify what the reader needs to predict, distinguish, decide, or do. Infer their background from context and define unfamiliar terms near first use. Ask only when missing information changes the answer.

Honor the requested language, medium, depth, and stage. A wording revision preserves the source's claims; a summary selects what matters without dropping conditions that change the conclusion; an explanation supplies the relationships or reasoning needed to understand it. Keep narrow edits narrow. For a rebuild, derive the organization from the question and evidence rather than retaining the previous layout by default.

Apply [language guidance](references/language.md) before composing. Use practical, STE-informed writing by default. "80% STE" describes a relaxed approach, not a measured compliance score. Use the official-standard checks in that reference when formal compliance is explicitly requested.

## Ground and compose the answer

Read the supplied material or relevant implementation. Keep actors, quantities, units, negation, uncertainty, obligations, exceptions, and AND/OR conditions intact. Preserve literal commands, identifiers, and quoted errors unless their modification is requested. Separate source claims, verified results, deductions, proposals, and illustrative examples. Do not invent a cause or actor to make an explanation smoother.

Lead with the answer, result, or cause. If it requires unfamiliar context, give only the orientation needed to make that answer meaningful. Follow with the evidence and mechanism, then the limits or next action that affect the reader's judgment.

Choose the progression and grouping for the question:

- **How or why:** trace a concrete case through intermediate causes or states; show a nearby contrast when it exposes the decisive condition.
- **A choice:** compare alternatives on the same criteria and state the condition that changes the recommendation.
- **A procedure:** put prerequisites before the actions they govern; keep simultaneous actions together and give a checkable result.
- **Work or results:** distinguish what changed, what was verified, and what is actually available to use. Group by actor, state, or time when that makes responsibility and remaining work clear. Include the next check or whether reader action is needed when relevant.

Give each paragraph one topic. Start with its point, then develop it using stable terms and explicit links such as cause, contrast, or sequence. Keep a fact and its decisive qualification together. Choose reading order deliberately; the order of notes or tool calls need not be the order of the explanation.

Headings, placement, and arrows also make claims. Do not imply an unsupported actor, completed state, or causal connection through grouping. Keep actions with unnamed actors outside actor groups, or say that the source does not name the actor.

Stop when the reader can make the intended judgment. Remove incidental history, repeated recaps, and sections that add no new understanding. Preserve the requested evidence and qualifications.

## Make the relationship visible

Use the requested medium. Otherwise choose what removes the main obstacle to understanding:

- Prose for a direct answer or derivation.
- A diagram for relationships, scope, branches, or sequence.
- Interactive HTML for changing inputs, comparing states, or exploring a model.
- Animation and narration for transformations that benefit from unfolding over time.

A custom, disposable artifact is useful when it makes the subject clearer. Produce it with available tools when that is the chosen deliverable. Do not require the reader to choose a level before helping, build every format, or add an automatic next-format offer. If an explanation fails, revisit its model or representation rather than adding more of the same prose.

For diagrams, HTML, or video, read the relevant section of [artifact delivery](references/artifacts.md). Carry the same facts and conditions into labels, controls, scenes, and narration. Each representation should do explanatory work.

## Verify and deliver

Check the delivered result for:

1. **Understanding:** the opening answers the question, each step supplies what the next needs, and the intended judgment is possible.
2. **Fidelity:** decisive conditions and uncertainty survive, including claims implied by placement. Trace a representative case and a relevant boundary or contrast.
3. **Execution:** verify the requested stage: wording, diagram render, working interaction, or playable video. Describe anything unmeasured or untested accurately.

Deliver the explanation itself, with the editable source for file outputs. State completion at the stage actually reached; source changes, successful checks, and an updated installation are different results. Give only usage notes and limitations that change what the reader can conclude or do.
