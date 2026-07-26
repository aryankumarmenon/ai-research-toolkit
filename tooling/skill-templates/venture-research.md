---
name: venture-research
description: Fan-out market research with a verification kill-pass — scope the questions, run parallel market-researcher subagents (competitors, market behavior, constraints, pricing), verify load-bearing claims, and synthesize one Research Digest with a verdict table.
disable-model-invocation: true
argument-hint: "<topic or question, e.g. 'competitors for the closed-loop mechanic'>"
allowed-tools: Read, Write, Grep, Glob, Task, WebSearch, WebFetch
---

# Venture Research

Run a verification-first desk-research pass for **<product name>** and produce
a single Research Digest the strategy work can stand on. Requires the
`market-researcher` and `claim-verifier` agents (installed to
`.claude/agents/` by the BUSINESS bundle).

**Run in fresh context** — research fan-outs are token-heavy; don't tack this
onto a working session.

## Process

### 1. Scope (one question at a time)
Ask, grilling-style, until you can write each researcher's brief in one
sentence: What decision will this research feed? What must be true for the
current plan to survive? What's explicitly out of scope? If the user passed a
topic in `$ARGUMENTS`, confirm the decision it feeds before proceeding.

### 2. Partition into question sets
Split into 2–4 **non-overlapping** sets, chosen from: competitors ·
market size & behavior · platform/regulatory constraints · pricing/costs.
Fewer, sharper sets beat full coverage — only spawn a set that feeds the
named decision.

### 3. Fan out (one message, parallel Task calls)
One `market-researcher` subagent per set. Each brief contains: the question
set, the decision it feeds, the claims protocol reminder (every claim
`[verified — source]` or `[hypothesis]`; "couldn't verify" is a first-class
result), and a hard format: the Finding/Verdict/Consequence table + detail,
under 600 words.

### 4. Verification kill-pass
Collect the load-bearing claims — the ones the decision actually turns on
(typically 3–8, not everything). Send them as a numbered list to one
`claim-verifier` subagent. Downgrade any claim it doesn't Confirm:
Contradicted findings flip, Unverifiable ones become `[hypothesis]` no matter
how confident the researcher sounded.

### 5. Synthesize the digest
Write `<research notes dir>/YYYY-MM-DD_<topic>.md`:
- The merged **Finding / Verdict / Consequence** table (verdicts post-kill-pass)
- **What we could NOT verify** — with search trails
- **Contradictions between researchers** — presented, not averaged
- **What this changes** — 2–4 lines mapping verdicts to the decision from Step 1

Report the table inline too; the file is for the next session.

## Rules

- Researcher outputs never merge raw — the kill-pass runs first. An unverified
  fan-out is just N opinions in parallel.
- Don't spawn a fourth researcher to break a two-researcher contradiction —
  surface it; the human or ceo-strategist owns the judgment call.
- ~15× single-session token cost is normal for fan-out research; if the
  decision is small, run one `market-researcher` directly instead of this flow.
