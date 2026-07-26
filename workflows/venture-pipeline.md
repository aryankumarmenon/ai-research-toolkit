# Workflow: Venture Pipeline (idea → validated plan → dev handoff)

The business-side sibling of [idea-to-ship.md](idea-to-ship.md). Where that
workflow takes a *feature* from idea to merged code, this one takes a *venture*
(a product idea, a side business) from hunch to a versioned plan with evidence
gates — and hands its build phases to the dev pipeline.

Runs on the BUSINESS bundle: six role agents
([`tooling/agent-templates/`](../tooling/agent-templates/)) + three flow skills
(`venture-research`, `venture-plan`, `design-critique`). Decision menu:
[`catalog/business-agents.md`](../catalog/business-agents.md).

```
idea ──► grill ──► research ──► verify ──► position ──► plan ──► gate reviews ──► dev handoff
         (grilling) (venture-      (claim-    (ceo-        (product-  (re-run per     (idea-to-ship /
                     research fan-  verifier   strategist   manager    phase result)    project dev
                     out)           kill-pass) + marketing) phases+gates)               pipeline)
```

## The route

1. **Grill** — one-question-at-a-time alignment on the idea itself: exact user,
   what they do today, the one structural mechanic, what counts as a kill
   signal. (Inside `/venture-plan`, or standalone via the `grilling` skill.)
2. **Research** — `/venture-research`: 2–4 parallel `market-researcher` agents
   on non-overlapping question sets, producing one Research Digest
   (Finding / Verdict / Consequence).
3. **Verify** — `claim-verifier` kill-pass on the load-bearing claims before
   the digest is trusted. External AI pastes (Gemini research etc.) enter here
   or not at all.
4. **Position & plan** — `/venture-plan` chains ceo-strategist (positioning,
   gates, riskiest assumption) → marketing-growth (GTM sketch) →
   product-manager (phased validation plan, MVP fence, kill switches) into one
   versioned venture doc.
5. **Gate reviews** — after each real-world phase (pilot, cohort, launch),
   bring the numbers back to `ceo-strategist` against the pre-committed
   continue/iterate/kill bands. Changing a gate *after* seeing the data is the
   failure mode; log any recalibration in the doc's version history.
6. **Dev handoff** — a phase that requires building enters the dev pipeline as
   PRD + vertical slices (the product-manager output is written to be consumed
   by grilling → PRD → issues). `/design-critique` runs on specs *before* they
   become slices.

## Invariants

- **Claims discipline end-to-end:** `[verified — source]` / `[hypothesis]`
  tags survive every hop; the assembled doc never strips them.
- **Cheapest evidence first:** concierge/manual phases before code; no phase
  may gate on a metric an earlier phase can't measure.
- **Pre-committed gates:** bands are written before the data arrives, with
  benchmarks cited or explicitly labeled placeholders.
- **One living doc:** the venture doc is versioned and superseded, never
  forked; research digests are dated files it imports.
- The workflow invariant holds here too: every phase ends on a verification
  loop (the gate), and interim planning artifacts are discarded once the doc
  absorbs them.
