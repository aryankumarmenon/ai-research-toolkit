---
name: venture-plan
description: Idea-to-venture-doc pipeline — grill the founder on the idea, then chain ceo-strategist (positioning + gates), marketing-growth (GTM sketch), and product-manager (phased validation plan) into one versioned venture doc with kill switches per phase.
disable-model-invocation: true
argument-hint: "<idea in one line, or path to an existing venture doc to revise>"
allowed-tools: Read, Write, Grep, Glob, Task, Skill
---

# Venture Plan

Turn an idea (or a stale venture doc) into a versioned plan for
**<product name>** — the business-side sibling of the dev pipeline
(grill → PRD → issues). Requires the `ceo-strategist`, `marketing-growth`,
and `product-manager` agents, plus the `grilling` skill.

## Process

### 1. Ingest
If `$ARGUMENTS` is a path, read the existing doc — this run produces the next
version, superseding, not rewriting. If a `/venture-research` digest exists in
`<research notes dir>`, read the latest one; its verdict table is the evidence
base. **No digest → every market claim in the output doc is `[hypothesis]` by
default**, and the doc's header must say the research pass hasn't run.

### 2. Grill the founder
Invoke the `grilling` skill on the idea. Branches that must be exhausted:
who exactly is the user · what they do today instead · the one mechanic that's
structurally different · what the founder would accept as a kill signal ·
budget/time box. Stop at shared understanding, per the skill.

### 3. Strategy (ceo-strategist subagent)
Brief: the grilling conclusions + the research digest. Ask for: positioning vs
named incumbents, phase-gate design (continue/iterate/kill bands with cited or
placeholder-labeled benchmarks), recommendation + riskiest assumption.

### 4. GTM sketch (marketing-growth subagent)
Brief: the positioning from Step 3. Ask for: positioning statement, one primary
channel per phase with stop rules, pricing framing. Sketch-depth — one page,
not a campaign plan.

### 5. Validation plan (product-manager subagent)
Brief: Steps 3–4 outputs. Ask for: phased plan (cheapest evidence first), each
phase with metric gates, cost, and kill switch; the "Deliberately out" table;
dev-pipeline handoff naming the first vertical slices.

### 6. Assemble the venture doc
Write `<venture doc path>` (or the next version of it), in this structure:
**Executive summary** → **Research digest** (imported table, or the
"research not run" banner) → **Positioning** → **Product spec / core
mechanic** → **Validation protocol** (phases + gates) → **GTM sketch** →
**Risk register** → **What would change our minds** → **Version history**
(one-line changelog entry for this run).

Every claim in the doc keeps its `[verified — source]` / `[hypothesis]` tag —
tags survive assembly; stripping them is the failure mode this whole flow
exists to prevent.

## Rules

- The pipeline is sequential by design — each agent consumes the previous
  output; don't parallelize steps 3–5.
- Agents' scope fences hold inside the flow: if the PM output contains
  strategy re-litigation or the CEO output contains feature specs, send it
  back to the right agent rather than merging it.
- The doc must stay cheap to abandon: no phase may depend on a gate that an
  earlier phase can't actually measure.
- This flow writes ONE file (the venture doc). Working notes from steps 2–5
  are conversation, not artifacts.
