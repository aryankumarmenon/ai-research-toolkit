# Agent Patterns

Subagent and multi-agent patterns, to pick by requirement. The two root reasons
to reach for a subagent at all (don't conflate them): **isolation by volume**
(a token-heavy task hands back a small summary, keeping the parent clean) and
**isolation for objectivity** (a reviewer's value is having *none* of the
author's context). Mechanics live in
[guides/context-and-subagents.md](../guides/context-and-subagents.md); this is the
menu.

## At a glance

| Pattern | Use when | Model tier | Relative cost |
|---|---|---|---|
| Research / Explore | Token-heavy search/lookup you want off the main thread | cheap (Haiku/Sonnet) | low |
| Reviewer | Check work against standards/spec without author bias | mid, fresh context | low–mid |
| Specialist review panel | A diff needs distinct lenses (design / idioms / standards / spec); pick 2–3 axes per diff | design=inherit, rest cheap | mid |
| QA / Testing | Generate + run tests on a change | cheap–mid | low |
| Domain-reference | Repeated lookups into a fixed external/read-only repo | cheap, read-only | low |
| Orchestrator | One question needs many parallel lookups synthesized | smart parent + cheap children | mid |
| Fan-out / fan-in † | Breadth **research** → one synthesis (not coding) | cheap children, smart synth | mid (≈15× chat) |
| Stochastic consensus † | Verify a **checkable** answer by agreement | cheap children, smart synth | mid–high |
| Evaluator–optimizer loop | Improve the *tooling itself* from how it's used | cheap hooks + on-demand review | ~free to log |
| Cross-session peers † | Two long-lived *sessions* need to consult each other | independent per session | low (no fan-out) |

† carries a **Maturity**/**Evidence** caveat — see the entry before relying on it.

**Second axis for every row above: fresh or forked?** Since v2.1.232 forking is
the default, and a forked child inherits the parent's conversation *and* prompt
cache — no 30–45k cold start. That makes the cheap rows cheaper still, but it is
**wrong for anything whose value is independence**: a forked Reviewer, QA agent,
or review-panel axis has already read the reasoning behind the code and will
ratify it. Rule of thumb: **fork for volume, fresh for judgement.** Full table:
[context-and-subagents.md → Fresh vs forked](../guides/context-and-subagents.md#fresh-vs-forked--the-spawn-mode-now-matters-as-much-as-the-model).

---

## Single-purpose subagents

### Research / Explore
**Use when:** a search, doc-read, or pattern-lookup would burn 50–100k tokens but
only ~2k matters to the parent.
**Pros:** keeps the expensive parent in the smart zone; big cost win.
**Cons:** results are only as faithful as the brief; one step removed from you.
**Efficiency:** cheap model, read-only, single-purpose. The default workhorse.
**Template / more:** roster in [context-and-subagents.md](../guides/context-and-subagents.md#subagents); real example = NAO `codebase-explorer` (haiku, read-only).

### Reviewer
**Use when:** you need work checked against standards or a spec *without* the
implementer's bias.
**Pros:** a blank slate catches deviations the author can't see; less context is
the entire point here, not a compromise.
**Cons:** must be fed the standards/spec explicitly — don't assume auto-load.
**Efficiency:** mid model, fresh context (ideally right after `/clear`).
**Never fork this one.** Forking is the default since v2.1.232, and a forked
reviewer inherits the conversation the code was written in — it reviews with the
author's bias, which is the one thing this agent exists to avoid. Spend the cold
start; it's the whole product here. Same for QA and every review-panel axis.
**Template / more:** [tooling/skill-templates/two-axis-review.md](../tooling/skill-templates/two-axis-review.md).

### Specialist review panel
**Use when:** a diff deserves more than one review lens — line-level correctness
isn't the same question as design quality or language fluency, and one
generalist reviewer reliably lets the "bigger picture" axis get crowded out by
line comments.
**Pros:** each specialist holds one rubric and nothing else, so the design axis
actually gets reviewed (a principal-engineer lens: depth/seams/dependency
direction/ADR conformance) instead of drowning under nitpicks. Officially
validated shape: Anthropic's `pr-review-toolkit` ships review as **6 focused
specialist agents**, and Dynamic Workflows' *adversarial verification* is the
same never-share-contexts principle.
**Cons:** compound `0.95^N` still applies — cap a single review at **2–3 axes
picked to match the diff**, not the full roster every time. Each specialist
must be fed its sources (ADRs, idiom guides) explicitly. False-positive risk
scales with reviewer count → the ≥75-confidence threshold + kill-pass are
mandatory, and axes are **never merged**.
**Efficiency:** design axis inherits the session model (real judgment);
idioms/standards axes pinned to sonnet (bounded judgment, high volume).
**Maturity:** `Running` — deployed in `sf-nao-admin` (design-reviewer + one
combined sf-idioms-reviewer as optional /review-diff axes). First real
design-axis run (2026-07-17, a real merge) surfaced one confirmed
triple-duplication bug at confidence 80 with zero padded findings — the
calibration (surface what clears the bar, no target count) held.
**Evidence:** Strong for the shape —
[`pr-review-toolkit`](../references/claude-code-plugins/plugins/pr-review-toolkit/)
(official 6-specialist roster) and two-axis review's never-merge rule; the
2–3-axis cap is our own inference from `0.95^N`, not field-tested.
**Template / more:** [tooling/agent-templates/design-reviewer.md](../tooling/agent-templates/design-reviewer.md) ·
[tooling/agent-templates/language-idioms-reviewer.md](../tooling/agent-templates/language-idioms-reviewer.md) ·
harness = [two-axis-review](../tooling/skill-templates/two-axis-review.md).

### QA / Testing
**Use when:** you want tests generated and run as a separate, verifiable step.
**Pros:** keeps "did it actually work" out of the implementer's optimistic context.
**Cons:** can pass vacuously if the brief is weak — demand meaningful assertions.
**Efficiency:** cheap–mid model; pairs with the verification-before-done rule.
**Template / more:** [tooling/skill-templates/tdd.md](../tooling/skill-templates/tdd.md).

### Domain-reference
**Use when:** a project repeatedly needs facts from a *fixed, read-only* external
codebase (e.g. a backend you integrate with but don't own).
**Pros:** scopes that knowledge into a cheap, single-purpose agent instead of
polluting the main context every time.
**Cons:** narrow by design; not for general reasoning.
**Efficiency:** cheap model, read-only, pinned to the reference path. Real example
= NAO `nao-server-reference`.

---

## Multi-agent patterns

> Constructive counterpart to the agent-teams *skepticism* (~7× token cost). The
> deciding question for all of these: **is there a real search space to cover, or
> just one task to execute?** If one right action exists, don't parallelize. Full
> treatment: [context-and-subagents.md → Parallel patterns](../guides/context-and-subagents.md#parallel-patterns-fan-in-and-consensus).

### Orchestrator (+ children)
**Use when:** one question fans into many independent lookups that then need
synthesis.
**Pros:** parent stays clean; children stay in the zone of good.
**Cons:** every extra hop from you dilutes faithfulness (compound `0.95^N`).
**Efficiency:** smart parent for synthesis, cheap children for legwork. Don't
spawn swarms for normal feature work.

### Fan-out / fan-in
**Use when:** broad, **read-only research** where breadth + a single good synthesis
beats a long linear pass. *Not* for coding with interdependent subtasks (see Cons).
**Pros:** for research, genuinely higher quality — Anthropic's production research
system (Opus lead + Sonnet workers) beat a single Opus agent by **90.2%** on their
internal eval.
**Cons:** ~**15× the tokens** of a normal chat — only worth it for high-value
research. And the win does *not* transfer to coding: Cognition ("Don't Build
Multi-Agents") found parallel subagents on interdependent work fragile, because
subagents can't see each other's assumptions. Breadth-gathering yes; shared-state
building no.
**Efficiency:** N cheap researchers → one smart synthesizer with a short prompt;
token usage alone explains ~80% of the quality variance (Anthropic).
**Maturity:** `Conceptual` (here) — not yet run in our own work, no template.
**Evidence:** Strong for the research use case, with an explicit boundary —
[Anthropic: multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system)
vs. [Cognition: Don't Build Multi-Agents](https://cognition.com/blog/dont-build-multi-agents).

### Dynamic Workflows
**Use when:** a task's right shape isn't known in advance — Claude decides, at
runtime, whether to fan out, run adversarially, or work linearly, instead of
you pre-committing to one fixed multi-agent template.
**Pros:** the harness adapts per-task instead of forcing every job through the
same orchestration shape; named patterns include fan-out-and-synthesize and
**adversarial verification** — a skeptic agent per producer, contexts never
shared, which is the official cousin of our own two-axis review's
never-merge-the-axes rule.
**Cons:** self-authored orchestration is harder to predict/debug than a fixed
template; still new enough that failure modes aren't well catalogued yet.
**Efficiency:** varies by the harness Claude authors at runtime — no fixed cost
model to quote.
**Maturity:** `Conceptual` — not run here.
**Evidence:** official blog —
[Dynamic Workflows in Claude Code](https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code);
verified in [research/2026-07-05_fable5-compound-stack-verification.md](../research/2026-07-05_fable5-compound-stack-verification.md).

### Stochastic consensus
**Use when:** a problem with a **constrained / checkable answer** (numeric,
factual, a discrete choice) where you want to filter errors by agreement.
**Pros:** this is **self-consistency** (Wang 2022) — sample N, take the majority —
a well-established win on reasoning benchmarks (GSM8K +17.9%, SVAMP +11%).
**Cons:** the voting only works when answers are *comparable*. For **open-ended
generation** (brainstorming, "all the ways to X" — the source video's actual demo)
there's nothing clean to vote on, so you get a deduped list, not real consensus.
More agents = more spend.
**Efficiency:** N varied-stance cheap agents → synthesizer aggregating by mode/vote.
**Maturity:** `Template, untested` here — validate aggregation quality + real token
cost before trusting it on a decision that matters.
**Evidence:** Strong for *constrained* answers, weak for *open-ended* —
[self-consistency (Wang et al. 2022)](https://arxiv.org/abs/2203.11171); note its
own stated limit on open-ended generation.
**Template / more:** [tooling/skill-templates/stochastic-consensus.md](../tooling/skill-templates/stochastic-consensus.md).

<!-- Multi-agent *debate* was evaluated and deliberately excluded: the evidence
has unguided debate underperforming plain self-consistency at equal token cost
([Cost of Consensus](https://arxiv.org/html/2605.00914v1), [LLMs Cannot
Self-Correct Reasoning Yet](https://arxiv.org/abs/2310.01798)). Use stochastic
consensus instead. Kept as a one-line note so it isn't re-proposed later. -->

---

### Cross-session peers
**Use when:** two *long-lived sessions* that would both exist anyway need to
consult each other — not when one task needs helpers. `SendMessage` + `ListAgents`
(≥v2.1.224; ≥v2.1.225 can open a conversation with a named Remote Control session
on another machine; ≥v2.1.232 adds `@`-mention by name in the prompt).
**Pros:** neither side pays to rebuild the other's context, and it reaches across
machines and cloud sessions. The only pattern here that is genuinely *peer* —
both sides are long-lived and neither owns the other's window.
**Cons:** it's a **message, not a call** — there's no return value to synthesize,
so the fan-out/fan-in and `0.95^N` reasoning doesn't transfer and neither do those
templates. Both peers are full-price instances. Discovery is by session name, and
the tools now warn when your account's session list was too long to check fully
rather than silently reporting a session as absent — treat "not found" as
"maybe not found". Auto mode's classifier vets outbound messages before dispatch.
**Efficiency:** low marginal cost precisely *because* there's no fan-out — but it
only pays when both sessions were going to be open regardless. Spinning up a
second session so it can be messaged is just a subagent with extra steps.
**Caution specific to this setup:** the obvious application here — bridging the
**company** Claude Code session and a **personal** research session — runs
straight at the boundary the 2026-08-16 full-cutover deliberately built
(`company/migration-plan.md`). A message is an intake path, and intake across
that line is exactly what the split exists to prevent. Decide the policy before
using it that way, not after.
**Maturity:** `Conceptual` — not run here; no template.
**Evidence:** platform primitive (official CHANGELOG v2.1.224/225/232); no
independent evaluation of whether peer coordination beats a shared state file,
which is the cheaper alternative this repo already uses (handoff docs).

## Feedback / self-improvement patterns

> These loops don't parallelize a task — they improve *the tooling* across
> sessions by feeding usage back into the rules. The generate→evaluate→revise
> shape is the canonical **evaluator–optimizer** pattern.

### Evaluator–optimizer loop (usage-logging self-improvement)
**Use when:** you want a `.claude/` tool suite (commands/agents/hooks) to get
*better over time* from how it's actually used — not just produce good output once.
**Pros:** near-free to capture — a handful of async hooks append a usage ledger
(`/commands`, subagent runs, file reads, compactions) that a periodic, on-request
review reads to spot dead commands, friction, or a step being skipped. The
"evaluate" half stays a deliberate human/AI pass, so it doesn't add per-session cost.
**Cons:** the log captures *that* something ran, not whether it went **well** —
quality still needs the review pass; it's fuel for reflection, not reflection
itself. And a Claude Code hook **can't see real token/context %** (verified — not
exposed to hooks), so context-hygiene checks are limited to mechanical proxies
(files-read count, re-reads) — scope drift stays a judgment call.
**Efficiency:** three async hooks (zero token cost) + one synchronous read-check
that can nudge back into context; review is on-demand only. Model tier: none for
capture, smart model for the periodic review.
**Maturity:** `Running` — built and in use in `sf-nao-admin` (four hooks →
`.claude/logs/usage.jsonl` + a `/retro` that reads it).
**Evidence:** the pattern is Anthropic's field-documented **evaluator–optimizer**
([cookbook notebook](../references/anthropic-cookbook-agent-patterns/evaluator_optimizer.ipynb));
the autonomous variant is the `ralph-wiggum` Stop-hook loop
([vendored](../references/claude-code-plugins/plugins/ralph-wiggum/)) and Karpathy's
auto-research ([research note](../research/2026-06-28_auto-research-and-harnesses.md)).
**Template / more:** [tooling/usage-logging-hooks/](../tooling/usage-logging-hooks/);
official hook-authoring shortcut = [`hookify`](../references/claude-code-plugins/plugins/hookify/).

### Outcome-grader loop
**Use when:** you want a task to iterate against a rubric until it passes,
without you re-steering it turn by turn.
**Pros:** the grader runs in a fresh, independent context each iteration with
the writer's full toolset — the same maker/checker split as a fresh-context
reviewer, but wired into an automatic iterate-until-pass loop instead of a
one-shot review. Native options exist at both scopes: `/goal` (session-local,
Stop-hook wrapper, Haiku transcript-judge, one active goal per session) and
Claude Managed Agents' Outcomes (cloud, `user.define_outcome` with a rubric +
`max_iterations` ≤20, default 3).
**Cons:** `/goal`'s judge can't run tools — it only reads the transcript, so it
can't independently re-verify claims, only judge what's reported. Outcomes is
cloud-only infra, out of reach for repos/rules that forbid attaching cloud
services (e.g. `sf-nao-admin`'s company-visibility + Devin-git-gate rules).
**Efficiency:** cheap judge model (Haiku) for `/goal`; iteration cost scales
with `max_iterations` for Outcomes.
**Maturity:** `Conceptual` — not run here.
**Evidence:** official docs + Anthropic's internal benchmarks reporting +10pp
task-success from outcome-graded loops —
[code.claude.com/docs/en/goal](https://code.claude.com/docs/en/goal),
[claude.com/blog/new-in-claude-managed-agents](https://claude.com/blog/new-in-claude-managed-agents);
verified in [research/2026-07-05_fable5-compound-stack-verification.md](../research/2026-07-05_fable5-compound-stack-verification.md).

