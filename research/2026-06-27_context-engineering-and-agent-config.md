# Context Engineering & Agent Config

General notes on managing an AI coding agent's context window and configuring
its instruction files / subagents for quality and cost. Sources: Pocock and
Saraev workflow videos (see `2026-06-27_ai-coding-workflow.md`) plus hands-on
config work. Tool-agnostic where possible; examples use Claude Code's file
layout because that's the concrete system, but the principles port.

---

## Why context is the bottleneck

The context window is shared by far more than your message. On a typical
session, *before you type anything*, 30–45k tokens are already consumed by:
system prompt + instruction files, tool definitions, MCP server tool schemas,
auto-memory, and skill front-matter. You are billed for all of it, and it's
the **highest-quality real estate** in the prompt — model reasoning is best
early in the window and degrades as it fills ("context rot" / leaving the
"smart zone," roughly past ~100k tokens regardless of the model's max window).

Implication: treat the early window as scarce and valuable. Don't waste it.

### Primacy / recency bias
Models (like people) remember the **beginning** of a stretch best, the end
second, the middle worst. So:
- Put the most critical, must-never-violate rules at the **very top** of your
  instruction file.
- Don't bury a hard constraint in the middle of a long doc.

---

## Instruction-file ("CLAUDE.md") best practices

The project instruction file is injected at the front of every session — it's
the initial trajectory for the whole conversation (a tiny angle error at the
port compounds over a long voyage). Treat it as high-leverage and keep it
tight:

- **Run the init/scan command** in any new repo to auto-generate a baseline
  from the actual code, then refine. A description of how the repo works is
  ~90% of the value and saves the agent from re-reading every file (which
  bloats context and lowers quality).
- **200–500 lines max.** Longer = more tokens every session + lower average
  quality. High information density: bullets, short headings.
- **Critical "never do X" at the top** (primacy).
- **Don't dump entire API docs / style guides into it.** Instead, have the
  agent prune an API down to the few endpoints/quirks actually needed, or move
  it to an on-demand skill.
- **Split a big file into rule files** (code style / testing / security /
  front-end …) for granular evolution and per-area ownership on a team.
- **Prune it like tech debt.** Left alone, agents accrete over-specific,
  low-value instructions over time. Periodically cut.
- **Add a rule when the agent repeats the same mistake 2–3 times** — cheaper
  than re-paying for that mistake every fresh session. (A running
  "recurring mistakes" doc is the natural home.)
- **Don't write vague aspirational rules** ("be smart," "make no mistakes").
  Intelligent-but-literal: too much rope and it hangs itself. Be specific.

### Instruction-file layering
Three merge layers, lowest to highest precedence: enterprise (managed) →
global (`~/.claude`) → project (`./.claude`). Plus a separate auto-`memory`
file the agent writes to itself. Use global for cross-project personal rules,
project for repo-specific ones.

---

## Active context management

- **Inspect** what's eating the window (Claude Code: `/context`). Do this once
  if you've never — the default overhead is eye-opening.
- **Clear** when switching to an unrelated task — don't drag stale context.
- **Compact** long histories into a dense summary (manual or automatic);
  persisted *documents* (spec, issues, handoff note) are the real memory, not
  conversation history. Prefer clearing to a known baseline over relying on
  lossy compaction.
- **Specific prompts** are the highest-ROI token saver: "fix this one thing in
  this file" beats "improve the codebase."
- **Extended thinking** offloads reasoning to a scratchpad that isn't carried
  forward in the message chain — blows up reasoning tokens but keeps the
  conversation lean. Tune effort to the task.

---

## Subagents: isolate context, use cheaper models

A subagent runs with its **own** context window and returns only a summary to
the parent. Two distinct reasons to use them:

1. **Context isolation by volume** — a research/search task might burn
   50–100k tokens exploring, but only needs to hand back a ~2k summary. Run it
   in a subagent on a cheaper model (Sonnet/Haiku); the parent (the expensive,
   smartest model) stays clean. Big cost + quality win.
2. **Context isolation for objectivity** — a *reviewer* subagent's value is
   that it has **no** context and therefore none of the author's bias. Same
   for a QA/test agent. Here, less context is the entire point (see workflow
   note's fresh-context review).

A solid default subagent roster: **research** (scoped, trusts specific
sources/docs), **reviewer** (blank slate, checks against pushed standards),
**QA/testing** (generates and runs tests). Keep their task definitions
**simple** — they're dumber than the parent, and spawning many multiplies
failure probability (0.95^N). Reserve the parent for synthesizing their
outputs, not for spawning swarms.

Model tiering rule of thumb: smartest/most-expensive model for the
orchestrating session and final synthesis; cheaper, longer-context models for
mechanical search, bulk reading, and parallel grunt work.

---

## Skills vs MCP — token economics

- **Skills** (custom command + optional scripts, an "orchestrator" pattern):
  only the **front-matter** (name + description + allowed tools) loads into
  context until the skill is actually invoked. So a dozen skills might cost
  ~60 tokens each at rest. Very cheap. The scripts inside run like tools, so
  the agent isn't re-deriving a repeatable procedure each time.
- **MCP servers** (someone else's tools): convenient to wire up, but the tool
  *schemas* load into context and bloated servers can eat 10–20% of the window
  instantly — more than all your skills combined. Some are far worse than
  others; be selective.
- **Practical pattern:** prototype with an MCP to prove a thing is possible,
  then *convert it to a skill* (find the underlying API, write a script) for
  the token-efficient repeatable version.
- Modern clients mitigate MCP bloat with on-demand tool search (don't load all
  schemas until needed) when MCP descriptions exceed ~10% of the window — but
  don't rely on that; prune servers you don't use.

---

## Quick checklist

- [ ] Init/scan to seed the instruction file; keep it 200–500 dense lines.
- [ ] Hard "never do X" rules at the very top.
- [ ] No full API docs/style guides dumped in — prune or move to skills.
- [ ] `/context` occasionally; `/clear` on task switch; lean on persisted docs.
- [ ] Subagents for context isolation (volume or objectivity), on cheaper models.
- [ ] Prefer skills over MCP for repeatable procedures; audit MCP token cost.
- [ ] Specific prompts; add a rule whenever a mistake recurs.
