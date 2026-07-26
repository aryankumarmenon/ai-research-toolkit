---
name: handoff
description: Compact the current conversation into a handoff document so a fresh agent can continue the work.
argument-hint: "What will the next session focus on?"
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Write, Bash
model: haiku
---

# Handoff

Write a handoff document summarising the current conversation so a fresh agent can
continue the work.

## Rules

- **Reference, don't duplicate.** Don't repeat content already captured in other
  artifacts (PRDs, plans, ADRs, issues, commits, diffs) — link them by path/URL.
- **Redact secrets** — API keys, passwords, PII.
- **Include a "suggested next skills" section** naming the skills the next agent
  should invoke.
- If the user passed an argument, treat it as what the next session will focus on
  and tailor the doc.

## Where to write it

<!-- Two conventions — pick one per project:
  A) Pocock default: the OS temp dir (out of the workspace), for a true fork.
  B) Project convention: a tracked docs/session-summary/ note, when the team
     expects handoffs in-repo. -->
Default: `<OS temp dir>/handoff-<topic>-<timestamp>.md`.

## Template

```markdown
## Feature / Task: <name>
## Branch: <git branch --show-current>
## Ticket: <id, if any>

### Completed this session
- [x] ...

### Remaining
- [ ] ...

### Blockers / known issues
- ...

### Key decisions made
- ...

### Files modified
- <from git diff --stat>

### Suggested next skills
- /<skill> — why

### Done when
- ...
```

## Judgment, not invention
Completed / Remaining / Blockers / Key decisions need judgment about what actually
happened. Where the diff and conversation don't make it clear, **ask the user**
rather than inventing plausible-sounding content.

## Doc-rot cleanup (optional, for in-repo handoffs)
If the task is fully done, fold the load-bearing bits of planning docs (spec
Out-of-Scope, open issues) into "Key decisions made", then delete the originals —
stale planning docs mislead the next session more than no doc. If the task isn't
done, leave them; they're still the working source of truth.
