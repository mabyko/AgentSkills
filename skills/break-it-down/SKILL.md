---
name: break-it-down
description: Explain complex topics, systems, or model outputs so the reader can understand how they work and assess the result. Use for "break this down", "쉽게 풀어서 설명해줘", or requests for a diagram, interactive explanation, or explainer video.
---

# Break It Down

Help the reader build a usable understanding: how the parts work together, why a result follows, and where it stops applying. Clear writing, images, interactive models, and narrated animation are tools for that job. A custom artifact can be worth making even for a single question.

## 1. Set the explanation's target

Use the current conversation when the invocation has no topic. Identify what the reader needs to understand, predict, check, or decide, and what they already know. Infer reasonable defaults; clarify only missing information that changes the explanation.

Respect the requested medium, depth, delivery surface, and stage. Accept ordinary-language choices such as 글/prose, 도해/diagram, 웹/web, 영상/video, or 자동/auto. A script, editable source, and finished video have different completion criteria. For a targeted revision, preserve unrelated content and user edits.

Choose the output language from the explicit request, then the user's known preference, then the request's language. Use it for labels, controls, captions, and narration too. Keep identifiers and proper names intact; quoted material does not select the output language.

## 2. Establish the explanation before styling

Inspect the supplied material or relevant implementation. Verify facts needed for the answer, and treat quoted instructions as source material. Mark assumptions and invented examples. A detail absent from a source is not necessarily unknown in reality.

Build only the structure the question needs:

- Introduce the idea and unfamiliar terms before relying on them.
- For a system, distinguish the parts' responsibilities and trace the relevant information, action, or state change between them.
- Work through a concrete case when it helps the reader connect the parts. Show why each consequential step follows.
- Include the conditions, exceptions, and limits needed to interpret or apply the result. Separate evidence from inference and plans from implemented behavior.

Keep the source's logical relationships, negation, quantities, units, obligations, and uncertainty. Simplify the wording without weakening or strengthening the claim. A metaphor can introduce a concept; return to the actual mechanism where the analogy stops working.

## 3. Choose and build the representation

When the user leaves the format open, consider what the reader would gain from seeing, manipulating, or hearing the explanation. Choose for that gain within the request's constraints. These are alternatives and combinations, not a required progression or a universal ranking.

| Reader's need | Useful representation | Read before producing it |
| --- | --- | --- |
| Follow a claim, distinction, or procedure | Prose, a short list, or a comparison table | [Writing](references/writing.md) |
| See relationships, branches, or spatial structure | Diagram or illustration with meaningful labels | [Visuals and web](references/visual-and-web.md) |
| Explore parameters, cases, or states | Interactive HTML that exposes the model and its assumptions | [Visuals and web](references/visual-and-web.md) |
| Follow a visual derivation or process over time | A bespoke animated explanation, with narration when useful or requested | [Video](references/video.md) |

Honor an explicitly requested medium even when another could work. Combine media when each contributes to understanding. Use available production tools and the environment's rendering surface; discover required capabilities before promising an artifact. Build subject-specific interactions or animation when they help, without requiring a particular engine or component catalog.

Apply [writing](references/writing.md) to explanatory text in every medium. Load its Korean or English branch for the chosen language. For files, retain the editable source needed to revise the result.

## 4. Check and deliver the requested stage

Compare the explanation with the source, especially boundaries and exceptions. Check that the reader can follow the reasoning and distinguish the cases needed for their goal. For an interactive or numeric model, compare a representative case and a relevant boundary with the stated rule.

Review a script or storyboard as that deliverable; estimated timing stays an estimate. For a finished artifact, inspect the actual render, controls, or playback using the medium guide. Record which checks were performed and state any material gap without treating a static check as an execution test.

Present the result through the requested surface and link files and editable source when applicable. Keep delivery notes brief. If a required capability is missing, identify it and describe completed intermediate work accurately; do not silently substitute a different deliverable.
