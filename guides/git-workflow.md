# Git workflow

How to branch, rebase, and merge in this repo — written 2026-08-10 after a
stray commit sat unmerged on a stale local branch for a week and caused a
three-way stash conflict to untangle. See journal 2026-08-10 for the incident.

## The rule in one line

**One branch = one topic = one PR. Branch from up-to-date `main`, rebase
instead of merge, merge via squash or rebase, delete the branch immediately.**

## Starting new work

```bash
git checkout main
git pull --ff-only          # or just `git pull` — pull.rebase=true is set locally
git checkout -b <type>/<short-topic>       # docs/, feat/, fix/, chore/
```

Branch prefixes match the commit-message convention already in use here
(`docs:`, `feat:`, `fix:`, `chore:` — see `git log`).

**Never resume work on a branch whose PR already merged.** If you have a new,
even loosely-related change, cut a fresh branch from `main`. This repo's
incident was exactly this mistake: a second commit landed on
`docs/oss-contribution-plan` *after* that branch's PR had already merged,
so it never got its own PR and sat orphaned, unpushed, invisible to `main`.

## While the branch is open

Keep it current with `main` by **rebasing, not merging main in**:

```bash
git fetch origin
git rebase origin/main
```

If `main` moved and your branch has commits worth keeping, rebase; don't
`git merge origin/main` into your feature branch — that creates a merge
commit and the exact tangled-conflict shape this doc exists to avoid.

## Finishing work

```bash
git push -u origin <branch>          # push.autoSetupRemote=true is set locally, -u is redundant but explicit
gh pr create --base main --head <branch> --title "..." --body "..."
gh pr merge --squash --delete-branch   # or --rebase for multi-commit history worth preserving
```

Repo-level GitHub settings now enforce part of this: the plain "Merge
commit" button is **disabled** on `aryankumarmenon/ai-research` (only Squash
and Rebase are available), and **Delete branch on merge** is **on** — the
remote branch cleans itself up. Local branch cleanup is still manual:

```bash
git checkout main && git pull --ff-only
git branch -d <branch>       # -D only if you're certain its content already landed
```

## Session-end checklist

Before ending any session that touched git:

1. `git status` — anything uncommitted?
2. `git log main..HEAD` (or `git log origin/<branch>..HEAD` if on a feature
   branch) — anything committed but not pushed?
3. If there's a PR open, is it merged? If merged, is the local branch deleted
   and `main` pulled?

A commit that exists only in a local branch is invisible to every future
session and to any fresh agent reading `STATE.md` — it doesn't exist until
it's pushed and merged. Never end a session with unpushed work you intend to
keep, unless you say so explicitly in the journal.

## Why rebase over merge here

- **Linear history is easier for an AI agent to reconstruct context from** —
  `git log --oneline` reads as a clean sequence of topics, not a lattice of
  merge commits.
- **Rebase surfaces conflicts against current `main` immediately**, while the
  change is still fresh in context — not days later when a second unrelated
  branch tries to land on top of stale content (this is what actually broke
  down in the 2026-08-10 incident).
- **Squash-on-merge means every `main` commit is a complete, reviewable unit**
  — no half-finished intermediate commits ("wip", "fix typo") permanently in
  history.

This is a solo repo, so there's no team-coordination cost to rewriting branch
history before it's merged (`git rebase`, `git commit --amend` on an *unpushed*
branch are both fine). Never rewrite history that's already on `main` or that
another clone might have pulled.
