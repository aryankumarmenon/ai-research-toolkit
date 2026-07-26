# Business-side role agents

Decision menu for the venture/business agent family — six role agents plus
three orchestrating flows. Deployables live in
[`tooling/agent-templates/`](../tooling/agent-templates/) and
[`tooling/skill-templates/`](../tooling/skill-templates/); the end-to-end route
is [`workflows/venture-pipeline.md`](../workflows/venture-pipeline.md).
Installed by `/onboard-project`'s BUSINESS bundle.

**The shared invariant:** claims discipline. Every market/competitor/platform
claim is `[verified — source]` or `[hypothesis]`, and external AI research
pastes stay unverified until `claim-verifier` passes them. This is what makes
the outputs composable — a downstream agent can trust an upstream tag.

## Which agent for which job

| You need… | Use | Not |
|---|---|---|
| A proceed/kill call, positioning, or gate design | `ceo-strategist` | PM (it plans what's already decided) |
| A PRD or phased plan with metrics + kill switches | `product-manager` | CEO (it decides, doesn't spec) |
| Positioning statement, channels, pricing framing, copy | `marketing-growth` | CEO (strategy ≠ the words) |
| A flow/spec critiqued or a screen designed (text spec) | `ux-designer` | marketing (voice ≠ UX) |
| Facts about the outside world | `market-researcher` | asking the session model from memory |
| A Gemini paste or a math section checked | `claim-verifier` | trusting the researcher's own tags |

## The role agents

### ceo-strategist / product-manager
**Use when:** direction or gates need deciding (CEO) → then turning into a buildable plan (PM).
**Pros:** clean split keeps decisions from being re-litigated inside plans; both end with falsifiable outputs (riskiest assumption / kill switches).
**Cons:** two hops for "just tell me what to build"; overkill for tiny decisions.
**Efficiency:** inherit session model · memo-sized outputs.
**Maturity:** Template, untested.

### marketing-growth / ux-designer
**Use when:** outward-facing words/channels (marketing) or screens/flows (UX).
**Pros:** hard scope fences (UX never codes; marketing never scopes features); UX findings confidence-scored like code review.
**Cons:** sonnet-pinned — fine for volume work, escalate genuinely novel brand strategy to the session model.
**Efficiency:** sonnet · bounded outputs (variants / ≤700-word critiques).
**Maturity:** Template, untested.

### market-researcher / claim-verifier
**Use when:** any outside-world question (researcher); before any external claim enters a doc (verifier).
**Pros:** the tag system + adversarial second pass is what earned the Bounce doc its `[verified]` credibility — codified here; "couldn't verify" is a first-class result.
**Cons:** verification doubles the calls on load-bearing claims (that's the feature).
**Efficiency:** sonnet · WebSearch-heavy, so token cost tracks question breadth.
**Maturity:** Template, untested. **Evidence:** self-consistency/verifier-pass gains are well documented for factual tasks (see `stochastic-consensus` entry's sources); pairing generator+checker mirrors the two-axis-review pattern proven here.

## The flows (skills)

### venture-research
**Use when:** a decision hangs on several outside-world questions at once.
**Pros:** fan-out breadth + a claim-verifier kill-pass before synthesis — N researchers without verification is just N opinions.
**Cons:** ~15× token cost of a single lookup; use one `market-researcher` directly for small questions.
**Efficiency:** 2–4 sonnet researchers + 1 verifier, parallel.
**Maturity:** Template, untested. **Evidence:** fan-out/fan-in research is the pattern behind Anthropic's multi-agent research system (90.2% eval gain — see `catalog/agents.md`).

### venture-plan
**Use when:** an idea (or stale venture doc) needs to become a versioned plan with gates.
**Pros:** the business mirror of idea→ship: grill → strategy → GTM → phased plan, one assembled doc, tags preserved end-to-end.
**Cons:** sequential by design — slow; wants a research digest first or everything lands `[hypothesis]`.
**Efficiency:** grilling is interactive; 3 sequential subagent passes after.
**Maturity:** Template, untested.

### design-critique
**Use when:** a spec section or flow needs UX eyes before building.
**Pros:** heuristics-pinned + kill-pass validated, so findings are quotable, not taste; ends in a buildable fix list.
**Cons:** needs written house heuristics to be sharp (its own first finding if absent).
**Efficiency:** 1 sonnet subagent + a validation pass.
**Maturity:** Template, untested.

## Natural next additions (not built)

- **cfo-analyst** — unit economics, pricing math, runway. Until then,
  `claim-verifier` re-derives any financial arithmetic.
- **compliance-researcher** — platform policy / regulatory sweeps as a
  standing role; today it's a `market-researcher` question set
  ("platform & regulatory constraints").
