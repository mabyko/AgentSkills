# Visual and interactive explanations

Start from the relationship or experiment the reader needs to understand. Choose a representation that makes it visible: a flow for branches, a sequence for messages over time, a map for responsibilities, or a chart for changing quantities. Label arrows with their meaning and quantities with their units. Mark invented values and proposed relationships.

## Diagrams and illustrations

Use an editable diagram format such as Mermaid or SVG for exact structure and labels. Use the available image workflow for an illustration that benefits from visual analogy or spatial detail. Preserve diagram source or the generation brief for revision.

Keep a clear reading order and enough context to interpret each part. Divide an overloaded diagram into related views instead of shrinking its text. Do not merge distinct actors merely to reduce node count.

For a finished diagram, render and inspect it at the delivered size. Check labels, arrow direction, branch conditions, overlap, and contrast. Compare its paths with the source. For a source-only request, check the source and identify unverified rendering.

## Interactive HTML

Define the learning interaction before adding controls: what the reader changes, which state or result changes, and what that reveals. Examples include stepping through a request, comparing two cases, or changing an input to see its consequence. A text-only response can be sufficient when text is the outcome; controls must still reveal something relevant to the explanation.

Show the current state, assumptions, units, and a useful initial example. Keep controls close to their effects. Give the reader a way to revisit a state or restore initial values when the experiment needs it. Keep explanatory text and visuals consistent with the selected state.

Use the requested stack or host surface. For an unspecified standalone format, prefer one HTML file with embedded styles, scripts, and required assets. External source links may remain links. Reuse appropriate components without restricting the explanation to their catalog. Retain editable content and model logic in the delivered source.

Before delivering a finished page:

1. Open the actual artifact using the environment's browser or preview workflow. Check desktop and narrow layouts for clipped content and unreadable diagrams.
2. Exercise the main interaction and relevant boundary or invalid inputs. Compare displayed results with the source model or a known calculation. Check reset or reverse navigation when provided.
3. Operate visible controls with the keyboard, check focus and labels, and ensure color is not the only way to interpret a state.
4. Check runtime errors, missing assets, and output-language consistency. If offline use was promised, verify that the required assets and data are bundled.

Report any checks that could not be performed. Source inspection alone does not verify interaction or rendering.
