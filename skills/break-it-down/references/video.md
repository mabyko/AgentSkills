# Explainer videos

Create a bespoke explanation of the requested topic, including animation, captions, and narration when requested. A 3Blue1Brown-style request calls for a coherent visual derivation: show objects, introduce changes, and reveal consequences in time with the explanation.

## Establish the deliverable

For a script or storyboard request, use the scene-planning steps and check the text, sequence, and estimated pacing. Deliver that stage as complete. For a finished-video request, continue through rendering and playback verification below.

Use the requested duration, output language, aspect ratio, narration preference, and delivery surface. If unspecified, choose a sequence long enough to develop the explanation and provide captions. Include voice when requested, or when a narrated sequence is the selected teaching approach and an appropriate speech workflow is available. Respect requests for silence. Use an available local or already-authorized speech workflow; an API key's presence alone is not authorization for paid usage.

Discover the available animation, speech, rendering, and export tools before committing to a pipeline. Use the current environment's supported workflow rather than assuming a specific library is installed. For a generic video request, default to a downloadable playable video file; honor an explicit format such as MP4. A player page is suitable when a web animation or HTML player was requested. Identify a missing required capability before promising the finished file.

## Build the scene sequence

1. Draft the explanation as scenes. Give each scene one concept or step, a visual, and its spoken or captioned beats. Start with the question or core model, then show the reasoning and its conclusion.
2. Make each beat introduce or change the corresponding visual element. Reveal arrows, values, branches, and outcomes at the point they are explained. Keep names and visual identity consistent across scenes so the reader can follow an object as it moves.
3. Use focus, highlighting, or camera motion to direct attention to the object currently being discussed. Keep the relevant context visible. Reuse a scene template or renderer for repeated mechanics; custom-build the transformation needed for the topic.
4. Write narration for speech in the chosen language. Explain notation and unfamiliar terms before relying on them. Preserve the factual qualifications from the source without reading dense technical prose verbatim.

## Render a finished video

Produce the audio when requested and use its measured duration to schedule beats. Otherwise allow enough time to read the captions. Render the animation and captions, then export the requested playable artifact.

When considering an installed answer-me-with-html renderer, read the [renderer adapter](answer-me-with-html.md).

## Verify and deliver the rendered result

- Play the exported artifact, including the beginning, transitions, and ending; check for blank scenes, cropped labels, and clipped captions. Verify full-file decoding when a suitable tool is available.
- Confirm the requested duration, dimensions, and format. Compare scene and caption timing with the narration; listen to pronunciation and pacing when voice is included.
- Check the explanation against the source. Motion must not imply a causal or chronological relationship that the source does not support.
- For a player page, exercise play/pause, replay, and seeking when supplied. Check that required media assets are available in the delivered package.
- Deliver the playable result plus the scene draft and captions or other editable source needed for revision. A script, storyboard, silent video, and narrated video are distinct deliverables; label the one actually produced.

When a required capability is unavailable, report the blocker and offer the completed source or intermediate artifact as a partial result. Do not describe a storyboard as a rendered video or quietly drop requested narration.
