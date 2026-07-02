# Bisect

Use this reference to find the commit that introduced a regression when you know a
"good" state and a "bad" state but not which commit between them broke things.
Bisect is a non-destructive investigation: it checks out old commits to test them but
does not rewrite history.

## When To Use

- The user reports "this used to work" or "this broke somewhere between X and Y".
- A test, build, or behavior passes at an older commit and fails at a newer one.
- The regression range is too large to inspect commit by commit.

## Manual Bisect

```bash
git bisect start
git bisect bad                 # current commit is broken
git bisect good <known-good-ref>
```

Git checks out a commit halfway between good and bad. Test it, then mark it:

```bash
git bisect good                # this commit is fine
git bisect bad                 # this commit is broken
```

Repeat until Git prints the first bad commit. Then always reset:

```bash
git bisect reset               # return to the original HEAD
```

## Automated Bisect

When a single command can decide good vs bad, let Git drive the whole search. The
script must exit `0` for good, non-zero for bad:

```bash
git bisect start HEAD <known-good-ref>
git bisect run <test-command>
git bisect reset
```

- Exit code `125` marks a commit as untestable/skipped rather than good or bad.
- Use a narrow, fast command so the search stays quick.

## Safety Notes

- Always finish with `git bisect reset`; leaving a bisect active detaches HEAD.
- Bisect changes the working tree; commit or stash local changes first
  (see `conflicts-recovery.md`).
- Report the first bad commit hash, its message, and how you verified it.
