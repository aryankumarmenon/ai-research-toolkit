# tooling/

Reusable Claude Code artifacts — **portable templates** ready to drop into any
real project's `.claude/`. Self-contained: no hardcoded paths, no
project-specific assumptions. Adapt the bracketed `<…>` placeholders per repo.

> Deciding *which* pattern you want first? Start at the
> [catalog/](../catalog/) (pros/cons + efficiency per pattern); it links back here
> for the deployable version.

| Template | Type | What it does | Source discipline |
|---|---|---|---|
| [context-capture/](context-capture/) | hook + command bundle | STATE.md snapshot + append-only journal + SessionStart auto-load + `/sync-context` writer — portable context system so every fresh chat starts with full project state | `ai-research` live system |
| [skill-templates/grilling.md](skill-templates/grilling.md) | model-invoked skill | One-question-at-a-time alignment interview | Pocock `grilling` |
| [skill-templates/tdd.md](skill-templates/tdd.md) | model-invoked skill | Red-green-refactor, vertical slices | Pocock `tdd` |
| [skill-templates/two-axis-review.md](skill-templates/two-axis-review.md) | user-invoked skill | Fresh-context Standards + Spec review via parallel subagents | Pocock `review` |
| [skill-templates/handoff.md](skill-templates/handoff.md) | user-invoked skill | Compact a session into a handoff doc | Pocock `handoff` |
| [skill-templates/stochastic-consensus.md](skill-templates/stochastic-consensus.md) | user-invoked skill | Fan out N varied-stance agents, aggregate by frequency (consensus + outliers) | Saraev Advanced course |
| [skill-templates/explain.md](skill-templates/explain.md) | user-invoked skill | Teach-on-demand: 3-level ladder (analogy → how it works here → trade-off), ≤250 words, `deeper`/`quiz me` follow-ups. Deployed globally at `~/.claude/skills/explain/` | `teach` (alexknowshtml) · Anthropic learning-output-style · original analogy-first |
| [agent-templates/](agent-templates/) | agent bundle (8 role agents) | Two families: business-side roles (ceo-strategist, product-manager, marketing-growth, ux-designer, market-researcher, claim-verifier; verification-first claims discipline) + dev-side review panel (design-reviewer, language-idioms-reviewer) | Bounce venture-doc practice · feature-dev plugin agent format · pr-review-toolkit |
| [claude-md-blocks/laziness-ladder.md](claude-md-blocks/laziness-ladder.md) | CLAUDE.md paste-in block | Pre-code decision ladder against over-engineering (YAGNI → reuse → stdlib → platform → dependency → one line → minimal code) with explicit non-negotiables | ponytail (vendored, §6 of references/README.md) |
| [skill-templates/venture-research.md](skill-templates/venture-research.md) | user-invoked skill | Fan-out market research (2–4 researchers) + claim-verifier kill-pass → one Research Digest | cookbook orchestrator-workers · Bounce research digest |
| [skill-templates/venture-plan.md](skill-templates/venture-plan.md) | user-invoked skill | Idea → versioned venture doc: grill → strategy → GTM → phased plan with gates/kill switches | idea-to-ship mirror · Bounce doc structure |
| [skill-templates/design-critique.md](skill-templates/design-critique.md) | user-invoked skill | Heuristics-pinned UX critique via ux-designer, confidence-scored, prioritized fix list | two-axis-review rubric |
| [usage-logging-hooks/](usage-logging-hooks/) | hook bundle (4 hooks + settings) | Append-only usage ledger (`/commands`, subagents, reads, compactions) + active in-session context-hygiene nudge | `sf-nao-admin` · cookbook `evaluator-optimizer` |

## How to use a template

1. Copy the file to `<project>/.claude/skills/<name>/SKILL.md` (skill) or
   `<project>/.claude/commands/<name>.md` (command).
2. Replace `<…>` placeholders: test command, standards file paths, doc locations.
3. Decide invocation (model- vs user-invoked) per
   [../guides/writing-skills.md](../guides/writing-skills.md) — the template's
   frontmatter has a sensible default.
4. Review `allowed-tools:` — each template carries a scoped whitelist appropriate
   to its job. Tighten or expand it if your repo's tools differ (e.g. replace
   `Bash` with a project-specific tool, or drop `Task` if you aren't using
   subagents).
5. Review `model:` — templates pin a cheap model (`haiku`) only where the task
   is mechanical; judgment-heavy templates inherit the session model. Override if
   you have a different cost/quality preference.
6. Keep the description's triggers tight; prune any line that's a no-op in your repo.

## Conventions

- Everything here must stay copy-able without edits beyond the placeholders.
- When a template proves itself in a real repo, fold improvements *back* here so
  the next project benefits — this is the single source of truth, the project
  copy is the deployment.
- New templates: follow the authoring rules in
  [../guides/writing-skills.md](../guides/writing-skills.md).
- All templates carry `allowed-tools:` and `model:` per the Agent Skills spec;
  see the "Frontmatter discipline levers" section of the guide for the full field
  set and when to use each lever.
