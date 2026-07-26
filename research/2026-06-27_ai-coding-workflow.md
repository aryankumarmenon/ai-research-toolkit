# AI Coding Workflow — Ticket to Handoff

General, reusable workflow for driving a non-trivial code change with an AI
coding agent, distilled from two sources plus hands-on experience building a
real pipeline:

- **Matt Pocock — "Full Walkthrough: Workflow for AI Coding"** (engineering
  workflow talk; his public `mattpocock/skills` repo: grill-me → to-prd →
  to-issues → tdd → review). Focused, senior-engineer framing.
- **Nick Saraev — "Claude Code Full Course 4 Hours: Build & Sell (2026)"**
  (breadth-first, general-audience; most demos are automation-agency
  monetization, but the *core principles* overlap with Pocock).
- Building a two-tool pipeline (one agent with repo/tracker access, one
  without) and getting the first design wrong before getting it right.

The two creators arrive independently at the same handful of principles —
that convergence is the signal worth keeping.

---

## The pipeline

```
intake → align → spec → slice → implement → review → handoff
```

1. **Intake** — collect everything knowable about the task *before* planning:
   ticket text, acceptance criteria, linked design docs, repro steps, related
   work. If the agent doing the thinking can't reach the source (no
   tracker/repo access), a *different* step/tool collects it and writes it to
   a file the thinking agent reads. Don't make a human relay context an
   integration could fetch.
2. **Align ("grill me")** — before any spec, the agent interviews the human
   **one question at a time**, proposing its own recommended answer each time,
   walking the decision tree until both could describe the solution the same
   way. This is the opposite of "edit this spec for me" — it builds shared
   understanding, it doesn't let the human author structure the agent doesn't
   grasp.
3. **Spec / PRD ("destination document")** — written *after* alignment, by
   synthesizing the conversation. Do **not** interview again here; do **not**
   proofread it line by line. Fixed sections: Problem / Solution / User
   Stories / Implementation Decisions / Testing Decisions / **Out of Scope**.
   The Out-of-Scope section is what actually defines "done."
4. **Slice into issues** — break the spec into small units. The single
   most-repeated correction in both sources: **slice vertically, not
   horizontally.** Never "01-schema, 02-api, 03-ui" — that delays integrated
   feedback to the very end. Each issue cuts through *every* layer for one
   thin piece of user-visible behavior, and is independently testable. Tag
   each with its blocking dependencies → forms a DAG, so work can parallelize.
5. **Implement** — pick the next unblocked issue. Write the failing test
   first (TDD red-green-refactor) so the agent can't write a test that merely
   ratifies whatever it already built. Keep each unit small enough to stay in
   the model's "smart zone" (see context note).
6. **Review in fresh context** — run the review in a *cleared* session, never
   appended to the session that wrote the code. The implementing agent is
   biased toward its own choices (it just spent its whole context justifying
   them); a blank-slate reviewer catches what the author structurally can't.
   Push the relevant standards into the reviewer's context explicitly rather
   than assuming auto-load fired.
7. **Handoff + cleanup** — write a durable handoff note, then **discard the
   planning artifacts** once implemented ("doc rot"): a PRD/issue list that
   has diverged from shipped code misleads the next session more than no doc
   at all. Close, don't archive.

---

## The principle under all of it: task → do → verify

AI's value is **not** one-shotting to 100% — humans are actually more precise
on the first try. Its value is the *speed of iterating* to ~100% via a
verification loop. So every task must have a way for the agent to judge its
own output:

- design work → screenshot-and-compare loop
- backend/logic → automated tests
- correctness against intent → the spec's Out-of-Scope + acceptance criteria

A workflow with no verification loop throws away most of the value. If
results are disappointing, the missing piece is almost always the loop.

---

## Plan before building

"A minute of planning saves ten minutes of building." Front-load research and
decisions in a cheap read-only planning phase. Building down a wrong approach
wastes the build time *and* the rebuild time *and* tokens; catching it in the
plan costs only the plan. This holds for any project work, not just AI.

---

## Lessons from getting it wrong

Real mistakes made while designing the pipeline, generalized:

- **Assign each step to the tool that has the access it needs.** First draft
  had the *thinking* agent try to collect ticket context it couldn't actually
  reach, leaning on the human to paste everything. Wrong. The step that needs
  tracker/repo access belongs to the tool that *has* it; hand the result off
  via a file. Don't bend a step to the wrong tool because that tool is the one
  you're sitting in.
- **Distinguish raw collected material from distilled output when deciding
  what to persist.** Raw dumps (full ticket threads, comment history) are
  verbose, contain noise/other people's chatter, and have no long-term value
  once a clean spec exists → keep local/transient. Curated decision-bearing
  docs (the spec, the issue breakdown) → persist and share. Committing
  everything pollutes history; committing nothing loses the useful record.
- **Default to the smaller first iteration.** When a later instruction *could*
  be read as "build the whole thing for everyone now," check it against any
  earlier "let's start small and iterate" intent before expanding scope. Ask
  rather than assume the broad reading. Full parity / full automation is
  almost always better deferred until the first real run has happened once.
- **Don't build on something flagged as bad.** When a human says "ignore X,
  it's not good," that means leave it untouched and build the new thing
  standalone — not make a small additive edit to X.
- **A blank-slate reviewer beats a polished one.** The reason fresh-context
  review works is *lack* of context, not more of it. Counter-intuitive, so
  it's easy to "helpfully" hand the reviewer the implementation rationale —
  which destroys the value.

---

## Things to apply by default

- One question at a time during alignment, always with a recommended answer.
- Spec is written once, after alignment — not negotiated word by word.
- Vertical slices, every time. Re-slice if you catch a by-layer breakdown.
- Failing test first.
- Review in a cleared session with standards pushed in explicitly.
- Throw planning docs away once the code lands.
- Always wire a verification loop; if you can't name it, the task isn't ready.

## Things to be skeptical of

- **Agent teams / large parallel swarms** — ~7× token cost, every teammate is
  a full instance; "a nuclear weapon aimed at your wallet." Real payoff is
  massive parallel *research/review* over an existing codebase, not building N
  variants of a thing. Don't reach for them on normal feature work.
- **Subagents as a cure-all** — spin-up overhead can exceed just doing the
  task inline; spawning many multiplies failure probability (0.95^N). Use them
  to isolate context (research, review) or to genuinely parallelize, not
  reflexively.
- **Over-adopting third-party planning frameworks** while the space is
  immature — prefer small custom commands/skills you fully understand over
  bolting on a heavyweight spec framework.
- **Shipping vibe-coded code with auth/payments/PII** without a real review
  pass — matters more the higher the stakes.
