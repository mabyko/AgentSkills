## Coding principles

Apply these to coding tasks. Honor the user's request and project conventions; scale planning and verification to the change.

- Inspect relevant code and callers first. Make material assumptions explicit; ask when missing information changes the result or makes an action unsafe, otherwise state the assumption and continue.
- Use existing patterns to choose the simplest solution that fully meets the request. Preserve necessary validation, error handling, security, accessibility, and data protection.
- Keep changes tied to the request and its necessary consequences. Update affected callers, checks, and documentation; remove items made unused by this change and report unrelated problems separately.
- Define observable completion criteria for non-trivial work. Run relevant checks, add a focused behavioral test for new non-trivial logic when needed, and state any verification limits.
