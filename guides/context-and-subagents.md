# Guide: Context Management & Subagents

The action-oriented companion to
[research/2026-06-27_context-engineering-and-agent-config.md](../research/2026-06-27_context-engineering-and-agent-config.md)
(read that for the *why*). This guide is the *what to do*.

## Why this is the bottleneck

Before you type anything, **30–45k tokens** are already gone: system prompt +
instruction files + tool definitions + MCP schemas + auto-memory + skill
frontmatter. The early window is the **highest-quality real estate** — model
reasoning is best early and degrades as it fills ("context rot"). Past the **smart
zone** (~120k tokens, regardless of the model's max window) quality drops. Treat
the early window as scarce.

**Primacy/recency:** models remember the *beginning* of a stretch best, the end
second, the middle worst. Put must-never-violate rules at the **very top** of an
instruction file; never bury a hard constraint in the middle.

## Active context management (the moves)

| Move | When |
|---|---|
| `/context` | Once if you never have — see the default overhead. Then before any optimization. |
| `/clear` | Switching to an unrelated task — don't drag stale context. |
| `/compact` | Long history, at an *intentional phase break*. Never mid-phase. |
| `/handoff` (fork) | You want a fresh session but need the current conversation preserved (cross a window). |
| Specific prompts | Always — "fix this one thing in this file" beats "improve the codebase". Highest-ROI token saver. |
| Extended thinking | Offload reasoning to a scratchpad not carried forward; tune effort to the task. |

**Persisted documents are the real memory, not conversation history.** Prefer
clearing to a known baseline (spec + issues + handoff on disk) over relying on
lossy compaction.

## Instruction files

The project instruction file is the *initial trajectory* of every session — a
tiny angle error at the start compounds. Keep it high-leverage:

- **Run init/scan** in a new repo to seed it from the actual code, then refine. A
  description of how the repo works is ~90% of the value and saves re-reading.
- **200–500 dense lines max.** Longer = more tokens every session + lower average
  quality. Bullets, short headings.
- **Critical "never do X" at the top** (primacy).
- **Don't dump entire API docs / style guides.** Prune to the few
  endpoints/quirks needed, or move to an on-demand skill.
- **Split a big file into rule files** (code style / testing / security / FE) for
  granular evolution and path-glob auto-loading.
- **Prune like tech debt.** Agents accrete low-value instructions; periodically cut.
- **Add a rule when the agent repeats a mistake 2–3 times** — cheaper than
  re-paying for it every fresh session. (A running "recurring mistakes" doc is the
  natural home — `sf-nao-admin/docs/RecurringMistakes.md` is exactly this.)
- **No vague aspirational rules** ("be smart"). Intelligent-but-literal: be specific.

**Layering** (low→high precedence): enterprise (managed) → global (`~/.claude`) →
project (`./.claude`), plus the auto-`memory` the agent writes itself. Global for
cross-project personal rules; project for repo-specific.

## Subagents

A subagent runs with its **own** window and returns only a summary. Two distinct
reasons — don't conflate them:

1. **Isolation by volume.** A research/search task might burn 50–100k tokens but
   hand back ~2k. Run it on a **cheaper model** (Sonnet/Haiku); the expensive
   parent stays clean. Big cost *and* quality win.
2. **Isolation for objectivity.** A *reviewer*'s value is having **no** context
   and therefore none of the author's bias. Same for QA. Here, less context is
   the entire point.

**A solid default roster:**
- **research / explore** — scoped, trusts specific sources/docs, read-only.
- **reviewer** — blank slate, checks against *pushed* standards.
- **QA / testing** — generates and runs tests.

Keep their definitions **simple** — they're dumber than the parent, and spawning
many multiplies failure probability (**0.95^N**). Reserve the parent for
*synthesizing* their outputs, not spawning swarms.

**Model tiering:** smartest/most-expensive model for the orchestrating session and
final synthesis; cheaper, longer-context models for mechanical search, bulk
reading, parallel grunt work. (My NAO `codebase-explorer` / `nao-server-reference`
are both haiku, read-only, single-purpose — the template.)

### Fresh vs forked — the spawn mode now matters as much as the model

Since **v2.1.232, forking is the default**: a `subagent_type: "fork"` child
inherits the **full conversation and the prompt cache** instead of cold-starting,
and non-teammate spawns in interactive sessions run in the background by default.

This maps *exactly* onto the two reasons above, in opposite directions — which is
why it's worth being deliberate rather than taking the default blindly:

| | Fresh spawn | Forked spawn |
|---|---|---|
| Pays the 30–45k cold start? | Yes | **No** — inherits the cache |
| Knows what you've been doing? | No — needs briefing | Yes, all of it |
| Carries the parent's bias? | **No — that's the point** | **Yes — unavoidably** |
| Right for | reason 2 (objectivity): review, QA, verification, adversarial checks | reason 1 (volume): search, bulk reading, mechanical grunt work |

The practical shift: delegation that was **too expensive to justify for a short
task** often isn't any more — a 5-minute lookup no longer costs a full cold
re-pay, so the "just do it in the main thread to avoid the overhead" instinct is
now frequently wrong. But the *reverse* is the trap to watch: **never fork a
reviewer.** A forked reviewer has read the whole conversation in which the code
was written, including your reasoning for it — it will ratify, not review. When
less context is the entire point, fresh is not the expensive option, it's the
only correct one.

**Delegation is no longer capped by total, only by shape.** The old
200-spawn-per-session cap was removed in v2.1.224; what still bounds you is
**20 concurrent** (`CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`, ≥v2.1.217) and
**spawn depth 3** (`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`, ≥v2.1.219). Setting a
stop condition is back to being *your* job. (The WebSearch 200/session cap does
still stand.)

**Be skeptical of swarms / agent teams:** ~7× token cost (every teammate is a full
instance — "a nuclear weapon aimed at your wallet"). Real payoff is massive
parallel *research/review over an existing codebase*, not building N variants of a
feature. Don't reach for them on normal feature work.

## Parallel patterns: fan-in and consensus

The flip side of the skepticism above — *when* the parallel spend is worth it,
and how to structure it so you get quality, not just cost. These exploit two
facts: LLMs are **stochastic** (the same prompt diverges run-to-run, so N runs
cover far more of the solution space than one), and each fresh subagent sits in
the **zone of good** (short context) instead of one long-context main thread.
The unifying shape is *spread the work across cheap parallel agents, then pay for
one smart synthesis.*

1. **Fan-out / fan-in.** Spawn N research subagents on a **cheap** model
   (Haiku/Sonnet), each on its own short context and a slightly different facet,
   then **one** synthesizer on a **smart** model (Opus) with a *short* prompt
   ("integrate overlaps, keep outliers, score them"). Beats a linear single-thread
   pass on time, cost, *and* quality — Anthropic's own finding is Opus + Sonnet
   subagents outperforms solo Opus. This is the *roster* idea above, applied to
   one question instead of a standing team.
2. **Stochastic consensus.** N agents each emit a *list* of solutions (vary the
   persona/reasoning stance per agent); the synthesizer counts the **mode** — how
   often each idea recurs. High frequency = consensus you can trust (this is what
   *filters hallucinations*); low frequency = genuine **high-variance outliers**
   worth a look. You want both. Strongest for *checkable* answers (it's
   self-consistency); on open-ended problems the vote is really just a dedup.

> A third pattern, *multi-agent debate*, was deliberately dropped — the evidence
> has it underperforming plain consensus at equal token cost. Default to
> stochastic consensus instead.

**When to reach for these vs. not:** worth it for open-ended *research, option
generation, and review* where breadth and hallucination-filtering pay off. Still
**not** worth it for ordinary feature implementation — that's the 7× wallet hit
with no upside. The deciding question is the same as for auto-research: is there a
real search space to cover, or just one task to execute?

A ready-to-adapt template lives at
[tooling/skill-templates/stochastic-consensus.md](../tooling/skill-templates/stochastic-consensus.md).

## Skills vs MCP {#skills-vs-mcp}

- **Skills** — only frontmatter loads at rest (~60 tokens each); the body and any
  scripts load on invocation. A dozen skills is cheap. Repeatable procedures
  belong here.
- **MCP** — tool *schemas* load into context; a bloated server eats 10–20% of the
  window instantly, more than all your skills combined. Be selective.
- **Pattern:** prototype with an MCP to prove a thing is possible → *convert it to
  a skill* (find the API, write a script) for the token-efficient repeatable
  version. On-demand tool search mitigates MCP bloat past ~10% of the window, but
  don't rely on it — prune servers you don't use.

## The official cost ladder (reach for these in order)

Anthropic's [Cost Optimization cookbook](https://platform.claude.com/cookbook/cost-optimization-cost-optimization)
(2026-08-09) sequences seven levers. It's worth following *in order* because the
cheap structural wins come first and the ones that cost you quality come last:

1. **Prompt caching** — biggest single lever; also what makes forking cheap.
2. **Input management via progressive disclosure** — load metadata, fetch bodies
   on demand (the same principle as skill frontmatter, applied to everything).
3. **Context editing / compaction** in the agent loop.
4. **Output-token constraints** — cap what comes back.
5. **Batch API** — for anything not interactive.
6. **Model / effort tuning** — the tiering above.
7. **Task decomposition to cheaper subagents** — last, not first.

The discipline that matters more than the list: **measure cost per *task*, not
per token, against an eval-backed quality baseline.** Cost per token can fall
while cost per task rises, if the cheaper setup needs three attempts. Most of
this repo already practices 1/2/6/7 piecemeal — this is the official ordering to
check that piecemeal practice against.

## Quick checklist

- [ ] `/context` run; overhead understood
- [ ] Instruction file 200–500 dense lines, hard rules at top, no dumped docs
- [ ] Rule files split by area; recurring-mistakes doc maintained
- [ ] `/clear` on task switch; persisted docs are the memory, not history
- [ ] Subagents for volume or objectivity, on cheaper models, simple definitions
- [ ] **Spawn mode chosen deliberately — forked for volume, never for review**
- [ ] **Stop condition set explicitly (the per-session spawn cap is gone)**
- [ ] Skills over MCP for repeatable procedures; MCP cost audited
- [ ] Specific prompts; a rule added whenever a mistake recurs
