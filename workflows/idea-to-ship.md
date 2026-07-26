# Workflow: Idea → Ship

The canonical route for any non-trivial code change. Distilled from Matt
Pocock's `ask-matt` main flow, Nick Saraev's course, and building the real NAO
pipeline (`sf-nao-admin`). Tool-agnostic; Claude Code mechanics are the concrete
example.

```
intake → align → spec → slice → implement → review → handoff
```

The single principle underneath all seven steps: **task → do → verify.** Every
step exists to either sharpen what "done" means or to give the agent a way to
check its own work against it.

---

## 0. Intake — collect before you plan

Gather everything knowable *before* thinking: ticket text, acceptance criteria,
linked design docs, repro steps, related prior work.

- **Assign this step to the tool that has the access.** If the thinking agent
  can't reach the source (no tracker/repo access), a *different* tool/step
  collects it and writes it to a file the thinking agent reads. Don't make a
  human relay context an integration could fetch. (In NAO: Devin's `arena`
  writes `docs/intake/<TICKET>.md`; Claude reads it.)
- Keep raw dumps (full ticket threads, comment history) **local/transient** —
  they're noisy and have no long-term value once a clean spec exists.

**Done when:** the thinking agent has, in a file or in context, everything it
needs to start asking sharp questions.

---

## 1. Align — "grill me" (the highest-leverage step)

Before any spec, the agent **interviews you one question at a time**, proposing
its own recommended answer each time, walking down each branch of the decision
tree and resolving dependencies between decisions one by one.

- **One question at a time.** Batching questions is bewildering and produces
  shallow answers.
- **Always a recommended answer attached.** This is alignment, not an exam.
- **Ground every question in real lookups.** If a question can be answered by
  exploring the codebase (or the backend contract), explore instead of asking.
  Never assume a helper/selector/DTO doesn't exist.
- This is the opposite of "edit this spec for me" — it builds *shared
  understanding*, it doesn't let the human author structure the agent doesn't grasp.

**The verbosity bonus:** do this *with* domain modeling (`grill-with-docs`) and
you also build a shared/ubiquitous language in `CONTEXT.md`. Then "there's a
problem with the materialization cascade" replaces a paragraph — and the agent
spends fewer tokens thinking, names things consistently, and navigates better.

**Done when:** both of you could describe the solution the *same way* without
referring back to the ticket. Don't manufacture more questions past that point.

---

## 2. Spec / PRD — the destination document

Written *after* alignment, by synthesizing the conversation. **No second
interview here; no line-by-line proofreading.** If something's materially wrong,
that's a sign step 1 needs to re-run, not that this doc needs editing.

Fixed sections:

| Section | What it holds |
|---|---|
| Problem Statement | What's broken/missing, from the user's perspective |
| Solution | The agreed approach, in plain language |
| User Stories | Long, numbered `As a <actor>, I want <feature>, so that <benefit>` |
| Implementation Decisions | Modules touched, interfaces, schema/contract changes — **no file paths or code snippets** (they go stale) |
| Testing Decisions | What makes a good test here, which modules, prior art |
| **Out of Scope** | **The section that actually defines "done."** Never skip it. |

**Seams first (Pocock's addition):** before writing, sketch the seams you'll test
the feature at. Prefer existing seams; use the highest seam possible; the ideal
number of new seams is *one*. Check the seams match the user's expectations.

---

## 3. Slice — vertical, never horizontal

Break the spec into small, independently-grabbable issues. **The single
most-repeated correction in every source:**

> **Slice vertically (tracer bullets), not horizontally.**

- **Wrong:** `01-schema`, `02-api`, `03-ui` — delays integrated feedback to the
  very end.
- **Right:** each issue cuts through *every* layer (schema + API + UI + tests)
  for one thin piece of user-visible behavior, and is demoable/verifiable on its own.
- Tag each with **blocking dependencies** → forms a DAG → work can parallelize.
- Do any **prefactoring first** ("make the change easy, then make the easy change").

Each issue: *What to build* (end-to-end behavior, no file paths) · *Acceptance
criteria* (checkable) · *Blocked by*.

---

## 4. Implement — one slice, test-first

Pick the next unblocked issue. **Start a fresh session per issue** (the issues
are independent — don't drag one's context into the next).

- **Red-green-refactor, one test at a time** (`/tdd`). Write the *failing* test
  first so the agent can't write a test that merely ratifies what it already
  built. One test → minimal code to pass → repeat. Never refactor while red.
- Test **behavior through public interfaces**, not implementation details — good
  tests survive refactors; tests that break on a rename were testing the wrong thing.
- Run typechecking regularly, single test files regularly, the **full suite once
  at the end**.
- Keep each unit small enough to stay in the model's **smart zone** (~120k tokens).

---

## 5. Review — in fresh context

Run the review in a **cleared session**, never appended to the session that wrote
the code. The implementer is biased toward its own choices (it just spent its
whole context justifying them); a blank-slate reviewer catches what the author
structurally can't.

- **Push the standards into the reviewer's context explicitly** — don't assume
  path-glob auto-load fired this session.
- **Two axes, run as parallel subagents** (Pocock's `review`): **Standards**
  (does it follow documented coding standards?) and **Spec** (does it match what
  the issue/PRD asked — including scope creep into Out-of-Scope?). Report them
  side by side; don't merge or rerank — one axis passing can mask the other failing.
- A blank-slate reviewer beats a polished one: the *lack* of context is the
  point, so don't "helpfully" feed it the implementation rationale.

---

## 6. Handoff + cleanup — fight doc rot

Write a durable handoff note (what's done, what remains, key decisions, files
modified, done-when). Then:

- **Discard the planning artifacts once the ticket is fully done.** A PRD/issue
  list that has diverged from shipped code misleads the next session *more* than
  no doc at all. Fold the load-bearing bits (Out-of-Scope, open decisions) into
  the handoff, then delete the originals. If the ticket *isn't* fully done, leave
  them — they're still the working source of truth.
- Handoff note goes somewhere durable and is the **first thing the next session
  (or Devin) reads**. Reference other artifacts by path; don't duplicate them.
  Redact secrets.

`/handoff` forks (new session, context preserved in a file); `/compact`
continues (same session, verbatim history lost). Use handoff to cross windows;
compact only at intentional phase breaks.

---

## Crossing into a prototype (the detour)

If a question in step 1–2 needs a *runnable* answer (does this state model feel
right? what should this look like?), detour:

```
/handoff out → fresh session → /prototype (throwaway code) → /handoff back
```

A prototype is **throwaway code that answers one question** — logic question →
tiny interactive terminal app; UI question → several radically different variants
on one route. No persistence, no tests, no polish. **Keep only the *answer*** (in
an ADR/commit/NOTES.md); delete or absorb the code.

---

## Quick checklist

- [ ] Intake collected by the tool that has access; raw material kept transient
- [ ] Grilled one-question-at-a-time until shared understanding; recommended answers given
- [ ] Spec written once, after alignment; Out-of-Scope filled; seams sketched (ideally one)
- [ ] Sliced vertically; dependencies form a valid DAG; prefactor first
- [ ] Implemented test-first, one slice per fresh session, within the smart zone
- [ ] Reviewed in fresh context, standards pushed in, Standards + Spec axes separate
- [ ] Handoff written; stale planning docs folded in and deleted
- [ ] **Every step had a verification loop. If you can't name it, the step wasn't ready.**
