# Writing the explanation

Apply the shared checks, then the branch for the output language. The default is readable prose informed by controlled technical writing. Formal ASD-STE100 review is a separate English-only task.

## Shared checks

Use familiar language where it carries the same meaning. Define necessary technical terms and use their names consistently. Preserve exact UI labels, identifiers, and units. Explain related but distinct operations separately, such as downloading a backup and restoring from it.

Present information in the order the reader needs it. State the main answer early when it is understandable; introduce a prerequisite concept first when necessary. Give reasons and examples enough room to explain the mechanism. Use numbered steps for a sequence, bullets for parallel items, and prose for a connected argument.

Before delivery, compare the meaning with the source:

- Do AND/OR conditions and their exceptions still apply to the correct actions?
- Are thresholds, units, dates, and comparison bases unchanged?
- Does permission remain permission, obligation remain obligation, and a possibility remain a possibility?
- Are causal links supported, and are unknown details still distinguished from confirmed facts?

For example, "expires after five minutes" does not establish whether data refreshes on a timer or on the next request. Explain the behavior the source actually specifies.

## Korean

Use natural Korean at the requested level of formality. English word limits and the STE dictionary do not define Korean correctness.

- Keep qualifications that carry meaning: 약, 최대, 일부, 아직, 경우에만, 미만, 이상. Do not turn "권장한다" into "해야 한다" or "할 수 있다" into a guarantee.
- Name the actor when responsibility would otherwise be unclear. Omit repeated subjects when the context is clear. Preserve a natural passive sentence when the state matters or the actor is not known; do not invent an actor to force active voice.
- Prefer a direct verb when it says the same thing. Keep established nouns such as "접근 권한"; unpack a chain of nouns when the relationship between them is unclear.
- Keep condition, cause, contrast, and simultaneous action connected. Split unrelated actions, but keep "버튼을 누른 채 손잡이를 당기세요" together if both actions must happen at once.
- Use short paragraphs with a clear focus. Review overloaded sentences by meaning, without a fixed Korean word or character limit. Avoid clipped memo fragments in an ordinary explanation.
- Match the genre and the reader's tone. An explanation does not need an obligatory action item or follow-up question. Remove ceremonial introductions and repeated conclusions when they add nothing.

Read the result as Korean, then compare it with the source again. Fluency does not establish fidelity.

## English: STE-informed default

For technical explanations and procedures, use these drafting targets from ASD-STE100 Issue 9. They guide ordinary explanations; meeting them alone does not establish compliance.

| Drafting choice | Issue 9 reference |
| --- | --- |
| Use a consistent name for the same technical item. | 1.11 |
| Clarify long noun groups; aim for at most three words, while handling longer technical names explicitly. | 2.1–2.2 |
| Prefer active verbs and direct actions to unnecessary nominalizations. Do not invent an unknown actor. | 3.6–3.7 |
| Aim for at most 20 words per procedural sentence. Give one instruction, except when actions must be simultaneous. Put a prerequisite before its action. | 5.1–5.4 |
| Aim for at most 25 words per descriptive sentence, one topic per paragraph, and at most six sentences per paragraph. | 6.3, 6.5–6.6 |

Keep necessary articles and logical links. A shorter synonym is useful only if it retains the intended meaning. Do not apply a blanket ban on passive voice or every word ending in "-ing". In ordinary explanations, prefer an accurate, natural sentence over a mechanical length target. Respect a requested narrative or conversational voice.

## When formal ASD-STE100 review is requested

1. Establish the requested issue. If none is given, check the [official standard site](https://www.asd-ste100.org/) for the applicable current issue. The table above refers specifically to [Issue 9](https://www.asd-ste100.org/assets/files/ASD-STE100_ISSUE9.pdf), dated January 15, 2025.
2. Read the official rules and dictionary. Identify the relevant document type and the permitted technical terminology. Check words by approved meaning, part of speech, and form, not merely spelling or a generic synonym list.
3. Apply the full relevant rules, including word-count conventions and exceptions. For example, Issue 9 approves APPROXIMATELY as an adverb; ABOUT is approved for a different meaning. Informal summaries are not dictionary authority.
4. State the issue and review scope, including unresolved vocabulary or rules. If the required material is unavailable, label the output an STE-informed draft and identify the unverified parts. Do not report certification or infer compliance from sentence length, an automated checker, or a percentage such as "80%".

Do not describe Korean output as formally compliant with this English standard.
