# Workflow: Debugging Loop

For hard bugs and performance regressions. Distilled from Pocock's
`diagnosing-bugs` skill. The whole discipline rests on one move: **build a tight,
red-capable feedback loop first.** Everything else is mechanical once you have it.

```
loop → reproduce+minimise → hypothesise → instrument → fix+regression-test → post-mortem
```

> The failure this workflow prevents: jumping straight to a hypothesis and
> reading code to build a theory *before a red-capable command exists*. No
> red-capable command → no hypothesising.

---

## Phase 1 — Build a feedback loop (this is the skill)

If you have a **tight** pass/fail signal that goes red on *this* bug, you will
find the cause. If you don't, no amount of staring at code saves you. Spend
disproportionate effort here. **Be aggressive, be creative, refuse to give up.**

Ways to construct one, roughly in order of preference:

1. **Failing test** at whatever seam reaches the bug (unit/integration/e2e).
2. **Curl / HTTP script** against a running dev server.
3. **CLI invocation** with a fixture, diffing stdout vs a known-good snapshot.
4. **Headless browser script** (Playwright/Puppeteer) asserting on DOM/console/network.
5. **Replay a captured trace** — save a real request/payload/event log, replay it in isolation.
6. **Throwaway harness** — minimal subset of the system, one function call hits the bug path.
7. **Property / fuzz loop** — for "sometimes wrong output", run 1000 random inputs.
8. **Bisection harness** — automate "boot at state X, check, repeat" for `git bisect run`.
9. **Differential loop** — same input through old vs new (or two configs), diff outputs.
10. **HITL bash script** — last resort; if a human must click, drive *them* with a structured loop.

**Tighten the loop** (treat it as a product): faster (cache setup, narrow scope),
sharper signal (assert the *specific* symptom, not "didn't crash"), more
deterministic (pin time, seed RNG, isolate fs, freeze network). A 2-second
deterministic loop is a superpower; a 30-second flaky one is barely a loop.

**Non-deterministic bugs:** the goal isn't a clean repro but a *higher
reproduction rate*. Loop 100×, parallelise, add stress, inject sleeps. 50% flake
is debuggable; 1% isn't — raise the rate until it is.

**Completion criterion:** you can name **one command** you've *already run at
least once* (paste invocation + output) that is red-capable (drives the real bug
path, asserts the user's exact symptom), deterministic, fast (seconds), and
agent-runnable. No such command → do not proceed to Phase 2.

---

## Phase 2 — Reproduce + minimise

Run the loop, watch it go red. Confirm it's the **user's** failure mode (not a
nearby different one — wrong bug = wrong fix), reproducible, and the exact symptom
is captured.

**Minimise:** shrink to the smallest scenario that still goes red. Cut inputs,
callers, config, data, steps **one at a time**, re-running after each cut. Done
when *every remaining element is load-bearing* — removing any one makes it green.
A minimal repro shrinks the hypothesis space and becomes the clean regression test.

---

## Phase 3 — Hypothesise

Generate **3–5 ranked, falsifiable hypotheses before testing any** (single-
hypothesis generation anchors on the first plausible idea).

> Format: "If X is the cause, then changing Y makes the bug disappear / changing
> Z makes it worse."

If you can't state the prediction, it's a vibe — discard or sharpen. **Show the
ranked list to the user before testing** — they often re-rank instantly ("we just
deployed #3"). Don't block on it if they're AFK.

---

## Phase 4 — Instrument

Each probe maps to a specific prediction. **Change one variable at a time.**

1. Debugger / REPL inspection if the env supports it — one breakpoint beats ten logs.
2. Targeted logs at the boundaries that distinguish hypotheses. Never "log everything and grep."
3. **Tag every debug log** with a unique prefix (`[DEBUG-a4f2]`) so cleanup is a single grep.

**Perf branch:** logs are usually wrong for regressions. Establish a baseline
measurement (timing harness, profiler, query plan), then bisect. Measure first,
fix second.

---

## Phase 5 — Fix + regression test

Write the regression test **before the fix** — *but only if a correct seam
exists.* A correct seam exercises the real bug pattern as it occurs at the call
site. If the only seam is too shallow (a unit test that can't replicate the chain
that triggered it), a test there gives false confidence — and **that absence is
itself the finding** (the architecture is preventing the bug being locked down).

If a correct seam exists: minimised repro → failing test → watch it fail → apply
fix → watch it pass → re-run the Phase 1 loop against the *original* scenario.

---

## Phase 6 — Cleanup + post-mortem

- [ ] Original repro no longer reproduces
- [ ] Regression test passes (or absent seam documented)
- [ ] All `[DEBUG-...]` instrumentation removed (grep the prefix)
- [ ] Throwaway prototypes deleted
- [ ] The correct hypothesis stated in the commit/PR message (so the next debugger learns)

**Then ask: what would have prevented this bug?** If the answer is architectural
(no good seam, tangled callers, hidden coupling), hand off to codebase-health
work *with specifics* — and make that recommendation *after* the fix is in, when
you know the most.

---

## When the loop above breaks down: test-suite-as-trust-boundary

Everything above assumes you can review each fix — one bug, one hypothesis, one
diff a human (or fresh subagent) can read. That assumption fails at a different
scale: a mass AI-driven rewrite or generation pass producing far more changed
surface than anyone can review line-by-line (e.g. porting a ~1M-line codebase
between languages).

At that scale, the discipline inverts:

- **The existing test suite becomes the sole merge gate.** Not "tests support
  review" — tests *are* the review. If the suite passes, the change merges,
  full stop. This only works if the suite was already trustworthy (comprehensive,
  not flaky) *before* the rewrite started — you can't retrofit trust into a
  gate at the moment you need it most.
- **Review targets the generator, not the generated.** When something's wrong,
  the fix isn't "patch this one instance" — it's "what about the generation
  pipeline produces this class of error, and how do we fix *that*." Adversarial
  review at this scale hunts for systemic pipeline flaws, not individual bugs.

This is a different failure mode from anything Phases 1–6 cover: those phases
are about finding root cause per-bug when a human can still hold the change in
their head. This is about what to do when they can't. Don't reach for it by
default — it only applies once per-instance review is genuinely infeasible;
otherwise the ranked-hypothesis loop above is sharper and cheaper.

Source: [Simon Willison, "Rewriting Bun in Rust"](https://simonwillison.net/2026/Jul/8/rewriting-bun-in-rust/) — an AI-driven Zig→Rust port of Bun used its existing TypeScript test suite as the conformance boundary for merging generated code.
