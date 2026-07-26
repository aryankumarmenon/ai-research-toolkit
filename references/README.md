# references/

Primary source material, **vendored** into this repo (not just linked) so it
can't rot. Each external source gets a written summary here so you can decide
whether to open the original.

| Reference | Form | Summary below |
|---|---|---|
| [`mattpocock-skills/`](mattpocock-skills/) | Full repo, vendored (commit pinned in `VENDORED.txt`) | [§1](#1-matt-pocock--skills-for-real-engineers) |
| [`claude-code-best-practice/`](claude-code-best-practice/) | **Curated** vendor — text/config only, media dropped ([INDEX.md](claude-code-best-practice/INDEX.md)) | [§2](#2-shanraisshan--claude-code-best-practice) |
| [`anthropic-skills/`](anthropic-skills/) | **Full** vendor — Anthropic's *official* Agent Skills repo (spec + template + example skills) | [§3](#3-anthropic--agent-skills-official) |
| [`claude-code-plugins/`](claude-code-plugins/) | **Curated** vendor — official Claude Code plugins + hook/settings examples ([INDEX.md](claude-code-plugins/INDEX.md)) | [§4](#4-anthropic--claude-code-plugins-official) |
| [`anthropic-cookbook-agent-patterns/`](anthropic-cookbook-agent-patterns/) | **Curated** vendor — the "Building Effective Agents" pattern notebooks | [§5](#5-anthropic-cookbook--building-effective-agents-patterns) |
| [`ponytail/`](ponytail/) | **Curated** vendor — the 32-line "lazy senior dev" ruleset + benchmark README; plugin machinery deliberately excluded | [§6](#6-dietrichgebert--ponytail-curated) |
| Matt Pocock — "Full Walkthrough: Workflow for AI Coding" | Video | [§7](#7-the-videos) |
| Nick Saraev — "Claude Code Full Course 4 Hours" | Video | [§7](#7-the-videos) |

> When you add a new external reference, vendor it under `references/<name>/`
> with a `VENDORED.txt` (source URL, clone date, commit), strip its `.git`, and
> add a summary section here.

---

## 1. Matt Pocock — "Skills For Real Engineers"

**Source:** https://github.com/mattpocock/skills · vendored at
[`mattpocock-skills/`](mattpocock-skills/) · `npx skills@latest add mattpocock/skills`

**Thesis.** Process frameworks (GSD, BMAD, Spec-Kit) "own the process" and take
away your control, so bugs in the process are hard to fix. Pocock's skills are
instead **small, composable, model-agnostic** units of engineering discipline
you adapt and own. Each targets a specific, named failure mode of coding agents.

### The four failure modes and their fixes

| Failure mode | Fix | Skill(s) |
|---|---|---|
| **Agent didn't do what I want** (misalignment — the #1 failure) | A relentless **grilling** session before any code | `grill-me`, `grill-with-docs` |
| **Agent is too verbose** | A **shared/ubiquitous language** (`CONTEXT.md` glossary) so 1 word replaces 20 | `domain-modeling` (built into `grill-with-docs`) |
| **Code doesn't work** | **Feedback loops**: types, browser, and red-green-refactor tests | `tdd`, `diagnosing-bugs` |
| **We built a ball of mud** | Care about **design** — deep modules, run a review every few days | `codebase-design`, `improve-codebase-architecture`, `to-prd` |

### The invocation axis (the repo's core organizing idea)

Every `SKILL.md` splits on **who can invoke it**:

- **User-invoked** — reachable *only* by the human typing its name. Set
  `disable-model-invocation: true`. Description is *human-facing* (no trigger
  lists). **Zero context load** (description isn't in the window) but spends
  **cognitive load** (you must remember it exists). Their job is to *orchestrate*.
- **Model-invoked** — reachable by model *or* user. Omit `disable-model-invocation`.
  Description is *model-facing* with rich trigger phrasing. **Costs context load**
  (description sits in the window every turn). Their job is to hold *reusable
  discipline*.

A user-invoked skill can invoke model-invoked skills, but **never another
user-invoked one** (the latter has no description for anything to reach). When
user-invoked skills outgrow memory, add a **router** skill (`ask-matt`).

### The skill catalog

**Engineering — user-invoked (orchestrators):**
- `ask-matt` — router over all the skills; "which flow fits my situation?"
- `grill-with-docs` — grilling that *also* builds the domain model (`CONTEXT.md` + ADRs) inline. Pocock's favourite technique.
- `to-prd` — synthesize the conversation into a PRD; **no interview**, publish to tracker.
- `to-issues` — split a plan/PRD into independently-grabbable **vertical-slice (tracer-bullet)** issues.
- `implement` — build from a PRD/issues, using `/tdd` at agreed seams; `/review` when done.
- `triage` — move issues/external PRs through a state machine of triage roles.
- `improve-codebase-architecture` — scan for shallow modules, present an HTML report, grill the chosen fix.
- `prototype` — throwaway code answering one question (logic: terminal app; UI: several variants on one route).
- `setup-matt-pocock-skills` — one-time per-repo config (issue tracker, labels, doc layout).

**Engineering — model-invoked (discipline):**
- `tdd` — red-green-refactor, **one** test→impl at a time (vertical), test behavior not implementation.
- `diagnosing-bugs` — Phase 1 is *build a tight, red-capable feedback loop*; everything else (minimise → 3-5 ranked hypotheses → instrument one variable → fix+regression test → post-mortem) just consumes it.
- `domain-modeling` — actively sharpen terms, write ADRs only when hard-to-reverse + surprising + a real trade-off; `CONTEXT.md` is a glossary, never a spec.
- `codebase-design` — exact vocabulary for **deep modules** (module/interface/implementation/depth/seam/adapter/leverage/locality) + the deletion test.

**Productivity:**
- `grill-me` / `grilling` — the relentless one-question-at-a-time interview (grilling is the reusable loop).
- `handoff` — compact a conversation into a handoff doc (in temp dir, redact secrets, reference don't duplicate, suggest next skills).
- `teach` — multi-session teaching using the cwd as a stateful workspace.
- `writing-great-skills` — the meta-reference for authoring skills (see [guides/writing-skills.md](../guides/writing-skills.md)).

**Misc:** `git-guardrails-claude-code` (PreToolUse hook blocking dangerous git),
`setup-pre-commit`, `migrate-to-shoehorn`, `scaffold-exercises`.

### The main flow (from `ask-matt`)

```
idea → /grill-with-docs → [need a runnable answer? → /handoff → /prototype → /handoff back]
     → multi-session? ── yes → /to-prd → /to-issues → (fresh session per issue) → /implement
                      └─ no  → /implement (same window)
     → /review
```
**Context hygiene:** keep grill→prd→issues in *one unbroken window* (don't
compact/clear) so they build on the same thinking; each `/implement` starts
fresh from its issue. The limit is the **smart zone** (~120k tokens) — `/handoff`
before you degrade.

**On-ramps:** `/triage` (work you didn't create) → produces agent-ready issues.
**Health:** `/improve-codebase-architecture` whenever you have a spare moment.

---

## 2. shanraisshan — "claude-code-best-practice"

**Source:** https://github.com/shanraisshan/claude-code-best-practice · vendored
**curated** at [`claude-code-best-practice/`](claude-code-best-practice/) (commit
in `VENDORED.txt`, navigate via [INDEX.md](claude-code-best-practice/INDEX.md)).
Upstream is ~146MB of mostly media; only the high-signal text + `.claude/` config
was kept (928K, ~85 md files). Full original clone remains at
`~/claude-code-best-practice` if media is ever needed.

**Thesis.** "From vibe coding to agentic engineering." Where Pocock is a focused
set of *workflow* skills, this is the **encyclopedia of Claude Code mechanics** —
a worked example of every feature with both a "best-practice" writeup and an
"implemented" sample. It's the place to look up *how a mechanism works*, not
*how to run a project*.

### What it covers (and where, on disk)

| Concept | In the repo |
|---|---|
| Subagents | `best-practice/claude-subagents.md`, `.claude/agents/*.md` |
| Commands | `best-practice/claude-commands.md`, `.claude/commands/*.md` |
| Skills | `best-practice/claude-skills.md`, `.claude/skills/*/SKILL.md` |
| Hooks | `.claude/hooks/` — `hooks.py`, `hooks-config.json`, per-event sound dirs |
| MCP | `best-practice/claude-mcp.md`, `.mcp.json` |
| Settings / permissions / model config | `best-practice/claude-settings.md`, `.claude/settings.json` |
| Memory & rules | `best-practice/claude-memory.md`, `.claude/rules/`, `agent-memory/` |
| Orchestration (one command driving subagents) | `orchestration-workflow/`, `.claude/commands/weather-orchestrator.md` |
| Agent teams (parallel swarms) | `agent-teams/` |
| CLI startup flags | `best-practice/claude-cli-startup-flags.md` |
| Power-ups, status line, output styles | `best-practice/claude-power-ups.md`, etc. |
| **Why the harness matters** (10 capabilities prompts can't replicate; prompt-a vs prompt-b; `Output = f(context, model, loop)`) | `reports/why-harness-is-important.md` — distilled into [research/2026-07-19_harness-and-loop-engineering.md](../research/2026-07-19_harness-and-loop-engineering.md) §2 |

### How I use it vs Pocock

- **Pocock = the verbs** (what to *do*: grill, slice, tdd, review).
- **best-practice = the nouns** (the *mechanisms*: how a hook fires, what goes
  in settings.json, how an orchestrator command spawns subagents).

(Table paths above are relative to the vendored copy; jump via
[claude-code-best-practice/INDEX.md](claude-code-best-practice/INDEX.md).)

The mechanics I've **distilled into [guides/](../guides/)** so I don't have to
re-read the encyclopedia each time: tool usage, skills-vs-commands-vs-agents-vs-hooks,
and context/subagent economics. Open the vendored files only for a worked sample
of a mechanism a guide references.

---

## 3. Anthropic — Agent Skills (official)

**Source:** https://github.com/anthropics/skills · vendored **full** at
[`anthropic-skills/`](anthropic-skills/) · install in a real repo with
`/plugin marketplace add anthropics/skills`.

**Thesis.** The *authoritative* source on what a Skill is and how to write one —
Anthropic's own spec, template, and a gallery of production + demo skills. Where
Pocock teaches the **discipline** (the invocation axis, the four failure modes),
this pins down the **standard**: the exact `SKILL.md` frontmatter, progressive
disclosure, bundled scripts/resources.

### What's inside (and why it matters here)

| Path | What | Use it for |
|---|---|---|
| [`spec/agent-skills-spec.md`](anthropic-skills/spec/agent-skills-spec.md) | The Agent Skills specification | The **primary-source backing** for [`../guides/writing-skills.md`](../guides/writing-skills.md) (previously Pocock-derived only) — cite this for the canonical frontmatter/structure rules. |
| [`template/`](anthropic-skills/template/) | Official empty skill template | Sanity-check `../tooling/skill-templates/` against the canonical shape. |
| [`skills/skill-creator/`](anthropic-skills/skills/skill-creator/) | A skill that *writes skills* | The meta-skill — read before authoring a new one. |
| [`skills/mcp-builder/`](anthropic-skills/skills/mcp-builder/), [`webapp-testing/`](anthropic-skills/skills/webapp-testing/) | Technical example skills | Worked patterns for MCP + browser-verification skills. |
| [`skills/docx,pdf,pptx,xlsx/`](anthropic-skills/skills/) | The **production** document skills | Reference for a *complex, real* skill (scripts + schemas + progressive disclosure), not a toy. |

**How it sits next to the others.** Pocock = the verbs, best-practice repo = the
nouns, **this = the official grammar** (the spec the nouns must obey). When the two
community sources and Anthropic's own spec agree on a rule, that rule is safe to
treat as settled.

---

## 4. Anthropic — Claude Code plugins (official)

**Source:** https://github.com/anthropics/claude-code (`plugins/` + `examples/`) ·
vendored **curated** at [`claude-code-plugins/`](claude-code-plugins/) — navigate via
[INDEX.md](claude-code-plugins/INDEX.md).

**Thesis.** Anthropic's **reference implementation** of the exact patterns this
workspace builds by hand — a real, shipped version of each to compare against.

- [`hookify/`](claude-code-plugins/plugins/hookify/) — author guardrail hooks from a
  natural-language rule + regex. The **official, ergonomic version** of the
  usage-logging / token-efficiency-nudge hooks built in `sf-nao-admin` (see the
  self-improvement-loop entry in [`../catalog/agents.md`](../catalog/agents.md) and the
  template in [`../tooling/usage-logging-hooks/`](../tooling/usage-logging-hooks/)).
- [`ralph-wiggum/`](claude-code-plugins/plugins/ralph-wiggum/) — "Ralph is a Bash loop":
  a **Stop hook** that blocks exit and re-feeds the prompt until a completion promise.
  The concrete Claude-Code realization of the **self-improvement / auto-research loop**
  in [`../research/2026-06-28_auto-research-and-harnesses.md`](../research/2026-06-28_auto-research-and-harnesses.md).
- [`feature-dev/`](claude-code-plugins/plugins/feature-dev/),
  [`code-review/`](claude-code-plugins/plugins/code-review/),
  [`pr-review-toolkit/`](claude-code-plugins/plugins/pr-review-toolkit/) — the official
  feature-build + review workflow; compare the agent split to the NAO pipeline and
  [`../tooling/skill-templates/two-axis-review.md`](../tooling/skill-templates/two-axis-review.md).
- [`plugin-dev/`](claude-code-plugins/plugins/plugin-dev/) — 7 authoring skills for
  plugins/commands/agents/hooks/skills/MCP; backs the guides.
- [`security-guidance/`](claude-code-plugins/plugins/security-guidance/) — 12 hooks doing
  real diff/commit security review — a worked example of hooks with teeth.
- [`examples/hooks/`](claude-code-plugins/examples/hooks/) + [`examples/settings/`](claude-code-plugins/examples/settings/)
  — the canonical PreToolUse validator + authoritative `settings.json` shapes.

Full plugin table and relevance notes live in the vendor's
[INDEX.md](claude-code-plugins/INDEX.md).

---

## 5. Anthropic Cookbook — "Building Effective Agents" patterns

**Source:** https://github.com/anthropics/claude-cookbooks (`patterns/agents/`) ·
vendored **curated** at [`anthropic-cookbook-agent-patterns/`](anthropic-cookbook-agent-patterns/).

**Thesis.** The canonical, code-level taxonomy of agent-design patterns — the
primary-source anchor for [`../catalog/agents.md`](../catalog/agents.md).

| Notebook | Pattern | Anchors |
|---|---|---|
| [`basic_workflows.ipynb`](anthropic-cookbook-agent-patterns/basic_workflows.ipynb) | Prompt-chaining, routing, parallelization | The fan-out/fan-in patterns in `../catalog/agents.md` + `../guides/context-and-subagents.md`. |
| [`orchestrator_workers.ipynb`](anthropic-cookbook-agent-patterns/orchestrator_workers.ipynb) | One orchestrator dynamically spawning workers | The subagent-roster + orchestration pattern. |
| [`evaluator_optimizer.ipynb`](anthropic-cookbook-agent-patterns/evaluator_optimizer.ipynb) | Generate → evaluate → revise loop | **The pattern the `sf-nao-admin` usage-logging self-improvement loop instantiates** — a generator whose output is critiqued and fed back. Cite this as the field-validated version. |
| [`async_multi_agent_orchestration.ipynb`](anthropic-cookbook-agent-patterns/async_multi_agent_orchestration.ipynb) | Async lead + parallel subagents (research-agent shape) | The parallel/stochastic-consensus patterns; `prompts/` holds the real lead/subagent/citations prompts. |

Anthropic's "Building Effective Agents" essay is the write-up; these notebooks are
its runnable form. Use them to check a `catalog/` entry against a reference impl.

---

## 6. DietrichGebert — ponytail (curated)

**Source:** https://github.com/DietrichGebert/ponytail · vendored at commit
`14a0d79` (2026-07-13, see `VENDORED.txt`).

**What:** the viral "lazy senior dev" ruleset (82k★, MIT) — an anti-over-engineering
**decision ladder** run before writing code: needs to exist (YAGNI)? → already in
the codebase? → stdlib? → native platform feature? → installed dependency? → one
line? → only then minimal code. Vendored curated: `AGENTS.md` (the whole ruleset
is 32 lines — genuinely tight) + `UPSTREAM-README.md` (benchmark methodology).
The plugin machinery (6 skills, hooks, per-platform rule copies) was deliberately
NOT vendored: an always-on ruleset in every context window contradicts our
instruction-file discipline, and `/ponytail-review`/`-audit` duplicate two-axis
review and codebase-health at lower quality. Even the community converged on
this — `ponytail-lite` strips it to one file.

**Why it earned a slot:** it's the **write-time counterpart to our review-time
defenses** — the design-reviewer and deletion test catch over-engineering after
it's written; the ladder prevents it being written. Its non-negotiables ("not
lazy about": trust boundaries, data loss, security, accessibility, one runnable
check per non-trivial change) keep it honest. Distilled for deployment as
[tooling/claude-md-blocks/laziness-ladder.md](../tooling/claude-md-blocks/laziness-ladder.md).

**Claims note:** the headline numbers (54% less code / 20% cheaper / 27% faster)
are the author's self-benchmark (12 tasks, n=4, Haiku 4.5, one repo) —
`[hypothesis]`, not verified; the older 80–94% figure is author-acknowledged as
partly inflated.

## 7. The videos

Principles, not demos, are what's kept. The first two are credited in
[research/2026-06-27_ai-coding-workflow.md](../research/2026-06-27_ai-coding-workflow.md);
the advanced course in [research/2026-06-28_auto-research-and-harnesses.md](../research/2026-06-28_auto-research-and-harnesses.md)
and [guides/web-automation-tiers.md](../guides/web-automation-tiers.md).

- **Matt Pocock — "Full Walkthrough: Workflow for AI Coding."** Senior-engineer
  framing; the public `mattpocock/skills` repo is its companion. Source of:
  grill → to-prd → to-issues → tdd → review, vertical slices, fresh-context review.
- **Nick Saraev — "Claude Code Full Course 4 Hours: Build & Sell (2026)."**
  Breadth-first, general audience; most demos are automation-agency
  monetization, but the *core principles* (plan before building, verification
  loops, specific prompts, context discipline) independently converge with
  Pocock. That convergence is the signal.
- **Nick Saraev — "Claude Code Advanced Full Course (3hr)."** The advanced
  follow-up. Source of three things new to this repo: the **agent-harness**
  mental model, the manual **self-improvement loop** → Karpathy's
  **auto-research**, and the three **web-automation tiers** (HTTP → browser →
  computer use). CLAUDE.md-compression basics from it were skipped as already
  covered.
