---
name: grilling
description: Grill the user relentlessly about a plan or design until shared understanding. Use when the user wants to stress-test a plan before building, align on a ticket, or uses any "grill" trigger phrase.
allowed-tools: Read, Grep, Glob, Task
---

# Grilling

Interview the user relentlessly about every aspect of this plan until you reach a
shared understanding — both of you could describe the solution the same way
without referring back to the original ticket.

Walk down each branch of the design tree, resolving dependencies between decisions
one at a time.

## Rules

- **One question at a time.** Wait for the answer before the next. Batching is bewildering.
- **Attach your recommended answer to every question.** This is alignment, not an exam.
  - **Exception:** for a hard-to-reverse decision, ask the user's own instinct
    *first*, then reveal your recommendation — leading anchors them on
    exactly the calls where that's costliest. Recommend-first everywhere else.
- **If a question can be answered by exploring the codebase, explore instead of asking.**
  Never assume a helper/class/component/contract doesn't exist — check first.
  <!-- For repos with a separate backend/contract, also confirm shapes there before asking. -->
- **"I don't know" → don't re-ask.** Explore the codebase to resolve it yourself,
  or offer 2-3 concrete options with trade-offs for the user to pick from.
- **Force one concrete example per key behavior**, restated as a Given/When/Then
  for the user to confirm before moving on — an example exposes a dimension an
  analogy can hide.
- **Stop at shared understanding.** Don't manufacture more questions past that point.
- **Do not act on the plan until the user confirms shared understanding has been
  reached.** Grilling ends with confirmation, never by sliding into implementation.

## Typical branches to resolve

Data model changes · whether existing records need backfill/migration · UI
placement and which existing pattern to follow · error/empty/edge cases · what's
explicitly **out of scope**.

## Pre-mortem before stopping

For non-trivial plans, before declaring completion ask the *user* to name 2-3 ways
this could ship and still be wrong or incomplete — you name none first, so their
surfacing preserves candor and avoids anchoring. Any real gap becomes one more
question, or an explicit out-of-scope line.

## Completion criterion

Stop when both hold: the open branches of the decision tree are exhausted, and the
pre-mortem surfaced nothing new — you and the user could independently describe the
solution the same way. Report that grilling is done and name the next step (e.g.
write the spec/PRD). This skill produces no file — the conversation is the artifact
the next step consumes.

<!-- To also build a domain glossary inline, pair with a domain-modeling skill:
     sharpen fuzzy terms into canonical ones and write them to CONTEXT.md as they
     resolve. See guides/writing-skills.md and Pocock's grill-with-docs. -->
