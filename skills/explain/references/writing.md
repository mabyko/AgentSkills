# Clear writing

Use ASD-STE100 as a writing guide for English procedures and technical descriptions. For Korean, general English, and other languages, apply its clarity principles in natural language. Karpathy's “80% of the way” is a request for a more relaxed style, not a compliance score.

## Draft

- Lead with the answer and give the context needed to interpret it. State who acts when the actor matters.
- Give each sentence a clear central point and each paragraph a coherent topic. Use common words and direct verbs; introduce necessary technical terms with a concrete explanation.
- Keep names stable. Replacing a technical term with a synonym for variety can imply a different concept.
- In procedures, separate actions the reader performs. Distinguish chronological steps from conditional branches and exceptions; an ordered list must not imply that every branch must be executed.
- Use short sentences as a readability aid, not as a reason to drop a qualification or break a logical link. Relax the style when strict technical phrasing makes an ordinary explanation harder to read. Follow the applicable standard's detailed limits only when the task calls for them and they have been checked.
- In Korean, retain natural subject omission and connective endings when the referent and relationship stay clear. Avoid forcing English word limits, Chinese character limits, or an explicit subject into every sentence. Match the reader's speech level.

## Compare with the source

Check the parts most likely to change during simplification:

- **Conditions and negation:** “only if both conditions hold” must not become “if either holds.”
- **Commitment:** “may improve” must not become “improves”; “refunds the duplicate charge” must not become “may refund it.”
- **Numbers:** retain units, bounds, reference dates, and distinctions such as calendar days versus business days.
- **Relations:** preserve the source's causal, contrastive, and temporal links. Add a causal explanation only when supported, or label it as a hypothesis.
- **Evidence:** a preference is not a measured benefit; an untested case is not a confirmed failure.

For example, “만료 시간을 5분으로 설정하면 오래된 결과가 남는 시간을 줄일 수 있지만, 시계가 다르면 5분 상한은 보장하지 않습니다” cannot be reduced to “캐시는 5분 안에 갱신됩니다.” Keep the limitation even if the sentence needs to be longer.

Use automatic length or vocabulary checks as aids. Review their language coverage and false positives before changing the text to satisfy them. A warning-free draft does not establish accuracy, comprehension, or ASD-STE100 compliance. If the user requests strict standard compliance, obtain the applicable specification and dictionary, validate against them, and report any checks that remain unavailable.
