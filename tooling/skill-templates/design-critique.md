---
name: design-critique
description: Run a UX critique of a named spec section, flow, or set of screens via the ux-designer agent — screen-by-screen findings against the project's stated heuristics, confidence-scored, ending in a prioritized fix list. No code.
disable-model-invocation: true
argument-hint: "<what to critique — spec section, doc path, or flow name>"
allowed-tools: Read, Grep, Glob, Task
---

# Design Critique

Critique a UX surface of **<product name>** against its stated heuristics,
via the `ux-designer` agent (installed to `.claude/agents/`).

## Process

### 1. Pin the subject
`$ARGUMENTS` names a spec section, file path, or flow. Resolve it to concrete
text/screens before spawning — if it's ambiguous ("the dashboard"), ask which
doc section or screens, and stop until pinned. A critique of an unpinned
subject critiques the critic's imagination.

### 2. Pin the heuristics
Collect the house heuristics from `<venture doc path or heuristics doc>`:
<project heuristics — e.g. core action ≤2 taps; supportive tone in all states;
works one-handed>. **Push them into the subagent's brief explicitly** — don't
assume it knows them. If the user wants extra lenses for this run (e.g.
"first-time-user eyes"), add them to the brief as temporary heuristics.

### 3. Spawn the ux-designer subagent
Brief contains: the pinned subject (text included, not just a pointer), the
heuristics, and the contract from the agent file — screen-by-screen walk,
taps counted, empty/error/recovery states checked, findings scored 0–100,
**surface only ≥75** (count the rest), each surfaced finding quoting the
heuristic or spec line it violates. Under 700 words.

### 4. Validate and present
Kill-pass the surfaced findings against the actual spec text: does the spec
really say/omit what the finding claims? Drop anything that doesn't hold.
Present: findings (validated) → **prioritized fix list** (confidence × impact,
one line each, buildable as written) → the below-threshold count.

## Rules

- Fix nothing — this flow reports; the implementing session (or the
  ux-designer in spec-writing mode) applies changes.
- One subject per run. "Also glance at onboarding" is a second run.
- If the project has no written heuristics yet, the critique's first finding
  is exactly that — offer to draft them with ux-designer before critiquing
  against taste.
