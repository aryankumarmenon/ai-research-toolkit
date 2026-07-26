# tooling/agent-templates/

Portable **role agents** — two families: the business side of a venture
(planning, research, positioning, design; the BUSINESS bundle) and the
**dev-side review panel** (specialist code reviewers). Counterpart to the
dev-side skills in [`skill-templates/`](../skill-templates/). Same portability
contract: no hardcoded paths, only bracketed `<…>` placeholders, filled at
install time.

Deploy to `<project>/.claude/agents/<name>.md`. Business agents are installed
automatically by `/onboard-project` when the project type includes
**venture/business** (the BUSINESS bundle); review-panel agents are copied by
hand for now (onboarding wiring is an open thread). 

| Agent | Model | Job in one line |
|---|---|---|
| [ceo-strategist.md](ceo-strategist.md) | inherit | Positioning, gate design (continue/iterate/kill), kill-or-scale calls; always ends with a recommendation + the riskiest assumption |
| [product-manager.md](product-manager.md) | inherit | Turns a validated direction into phased plans with metrics, MVP fences, and acceptance criteria; hands off to the dev pipeline |
| [marketing-growth.md](marketing-growth.md) | sonnet | Positioning statements, GTM/channel plans, pricing framing, product-voice copy |
| [ux-designer.md](ux-designer.md) | sonnet | Screen-by-screen UX critique + text wireframe specs; never writes code |
| [market-researcher.md](market-researcher.md) | sonnet | Verification-first desk research; every claim `[verified — source]` or `[hypothesis]`; outputs a Research Digest table |
| [claim-verifier.md](claim-verifier.md) | sonnet | Adversarial checker for external AI pastes and math; Confirmed / Contradicted / Unverifiable per claim |

## Review panel (dev-side)

| Agent | Model | Job in one line |
|---|---|---|
| [design-reviewer.md](design-reviewer.md) | inherit | Principal-engineer axis: module depth, seams, dependency direction, ADR conformance, silent architectural decisions; SOLID as a lens, never a checklist |
| [language-idioms-reviewer.md](language-idioms-reviewer.md) | sonnet | Language fluency axis, filled in when the language is decided; strictly above what linters enforce; one copy per language in polyglot repos |

Panel discipline (same as [two-axis-review](../skill-templates/two-axis-review.md)):
each reviewer runs in **fresh context, in parallel**, findings scored 0–100 with
only ≥75 surfaced, a false-positive kill-pass before presenting, and axes
**never merged** — no reviewer's findings mask another's. Cap a single review at
2–3 specialist axes (compound `0.95^N` — see
[catalog/agents.md](../../catalog/agents.md)); pick the axes that match the
diff, don't run the full roster every time.

## Shared discipline (all six)

- **Claims discipline:** any factual claim about the market, competitors,
  platforms, or regulation is either `[verified — <source>]` or `[hypothesis]`.
  No third category. External AI output (Gemini, blog posts) is unverified
  input until `claim-verifier` has passed it.
- **Scope fences:** each agent's file ends with a "Refuses to do" section.
  Role agents that drift into each other's lanes produce mush — the fences are
  the point.
- **Model choice:** strategy/PM judgment inherits the session model; research,
  verification, critique, and copywriting are pinned to `sonnet` (high volume,
  bounded judgment). Override per repo if your cost preference differs.

## Orchestration

These agents are designed to be driven by the flow skills in
[`skill-templates/`](../skill-templates/): `venture-research.md`,
`venture-plan.md`, `design-critique.md`. The end-to-end route is
[`workflows/venture-pipeline.md`](../../workflows/venture-pipeline.md);
the decision menu is [`catalog/business-agents.md`](../../catalog/business-agents.md).
