# Submodules

Use this reference for Git submodule work: cloning a repo that contains submodules,
adding a submodule, updating pinned submodule commits, and removing a submodule.
Only use this reference when the repository actually contains submodules (a
`.gitmodules` file) or the user explicitly asks to add one.

## Detect Submodules

```bash
git submodule status
cat .gitmodules
```

If there is no `.gitmodules` file and the user did not ask to add one, the repo has
no submodules; do not introduce them.

## Clone With Submodules

```bash
git clone --recurse-submodules <url>
```

For an already-cloned repo that is missing submodule contents:

```bash
git submodule update --init --recursive
```

## Add A Submodule

```bash
git submodule add <url> <path>
git commit -S --signoff -m "chore: add <name> submodule"
```

Adding a submodule stages both `.gitmodules` and the new submodule path. Commit them
together in one atomic commit.

## Update A Pinned Submodule

A superproject pins each submodule to a specific commit. To move a submodule to a
newer upstream commit:

```bash
git -C <path> fetch
git -C <path> checkout <ref>
git add <path>
git commit -S --signoff -m "chore: bump <name> submodule to <ref>"
```

To fast-forward all submodules to their tracked remote branches:

```bash
git submodule update --remote --merge
```

Review what changed before committing; a submodule bump can pull in large upstream
changes.

## Remove A Submodule

```bash
git submodule deinit -f <path>
git rm <path>
rm -rf .git/modules/<path>
git commit -S --signoff -m "chore: remove <name> submodule"
```

## Safety Notes

- A submodule pointer is just a commit SHA; committing the superproject records which
  submodule commit it expects. Always commit the superproject after changing a
  submodule.
- After pulling superproject changes, run `git submodule update --init --recursive`
  so submodule working trees match the pinned commits.
- Do not push superproject commits that reference unpushed submodule commits; push
  the submodule first.
