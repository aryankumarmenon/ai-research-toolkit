---
name: tdd
description: Test-driven development with a red-green-refactor loop. Use when the user wants to build a feature or fix a bug test-first, mentions "red-green-refactor", or wants integration tests.
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

# Test-Driven Development

## Philosophy

Tests verify **behavior through public interfaces**, not implementation details.
Code can change entirely; tests shouldn't. A good test reads like a specification
("user can checkout with valid cart") and survives refactors. A test that breaks
when you rename an internal function was testing implementation — the warning sign.

## Anti-pattern: horizontal slices

**Do NOT write all tests first, then all implementation.** Tests written in bulk
test *imagined* behavior — they pass when behavior breaks and fail when it's fine.

```
WRONG (horizontal):  RED: test1..test5   then  GREEN: impl1..impl5
RIGHT (vertical):    RED→GREEN: test1→impl1, test2→impl2, ...
```

One test responds to what you learned from the previous cycle.

## Workflow

### 1. Plan
- [ ] Confirm the public interface that's changing.
- [ ] Confirm *which behaviors to test*, prioritized — you can't test everything; focus on critical paths and complex logic.
- [ ] List behaviors (not implementation steps). Get user approval.
<!-- If the repo has a domain glossary (CONTEXT.md), use its vocabulary in test names. -->

### 2. Tracer bullet
Write ONE test for the first behavior → it fails (RED) → minimal code to pass
(GREEN). Proves the path end-to-end.

### 3. Incremental loop
For each remaining behavior: RED (next test fails) → GREEN (minimal code passes).
- One test at a time. Only enough code to pass the current test. Don't anticipate future tests.

### 4. Refactor (only while GREEN — never refactor while RED)
Extract duplication; deepen modules (complexity behind a simple interface); apply
SOLID where natural; re-run tests after each step.

## Per-cycle checklist
```
[ ] Test describes behavior, not implementation
[ ] Test uses the public interface only
[ ] Test would survive an internal refactor
[ ] Code is minimal for this test
[ ] No speculative features added
```

## Running tests
<!-- Replace with the project's commands. -->
- Single test file (fast loop): `<command to run one test file>`
- Full suite (once, at the end): `<command to run all tests>`
- Typecheck regularly: `<typecheck command>`
