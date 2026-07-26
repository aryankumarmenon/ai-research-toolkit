# Skill Patterns

Skill patterns, to pick by requirement. A skill is a **repeatable procedure** —
only its frontmatter (~60 tokens) loads at rest, the body loads on invocation, so
a dozen skills is cheap. Prefer a skill over an MCP for anything repeatable (see
[skills-vs-MCP economics](../guides/context-and-subagents.md#skills-vs-mcp)). How
to *author* one well: [guides/writing-skills.md](../guides/writing-skills.md). This
is the menu of *which* to build.

## At a glance

| Pattern | Use when | Invocation | Cost at rest |
|---|---|---|---|
| Alignment / grilling | Before building anything non-trivial | user or model | ~frontmatter only |
| TDD slice | Implementing a vertical feature slice | model | ~frontmatter only |
| Two-axis review | Checking a diff before handoff | user (fresh ctx) | ~frontmatter only |
| Handoff | Crossing a context window / ending a session | user | ~frontmatter only |
| Stochastic consensus † | Open-ended option generation | user | ~frontmatter only |
| Mistake/retro log | Stopping repeated errors across sessions | convention, not a skill | n/a |

† carries a **Maturity** caveat (template written but not yet run in a real repo) — see the entry.

---

### Alignment / grilling
**Use when:** a task is non-trivial and you're not yet sure *what* it requires —
align before a line of spec is written.
**Pros:** one question at a time, grounded in real lookups, kills wrong
assumptions early; the conversation *is* the artifact.
**Cons:** feels slow on tasks that were actually simple — skip it for those.
**Efficiency:** cheap at rest; spends tokens only during the interview.
**Template / more:** [tooling/skill-templates/grilling.md](../tooling/skill-templates/grilling.md).

### TDD slice
**Use when:** implementing a feature you can carve into a *vertical* slice
(schema+logic+UI together, never by layer).
**Pros:** red-green-refactor gives the agent its own verification loop — the whole
point of AI value.
**Cons:** needs a real test command and a sliceable feature; overkill for a typo.
**Efficiency:** model-invoked; the test run is the cost, and it's worth it.
**Template / more:** [tooling/skill-templates/tdd.md](../tooling/skill-templates/tdd.md).

### Two-axis review
**Use when:** a diff is ready and you want it checked against *both* standards and
spec before handoff.
**Pros:** parallel subagents in fresh context catch what the implementer can't;
the two axes stop one masking the other.
**Cons:** must run in a *clean* session, not tacked onto the implementing one.
**Efficiency:** user-invoked; spawns two cheap-ish reviewers.
**Template / more:** [tooling/skill-templates/two-axis-review.md](../tooling/skill-templates/two-axis-review.md).

### Handoff
**Use when:** crossing a context window or ending a session with work unfinished.
**Pros:** persisted doc is the real memory; a fresh session loses nothing.
**Cons:** stale handoffs rot — fold/delete them once the work lands.
**Efficiency:** user-invoked, cheap; saves a far larger re-derivation cost later.
**Template / more:** [tooling/skill-templates/handoff.md](../tooling/skill-templates/handoff.md).

### Stochastic consensus
**Use when:** a **checkable** question (numeric/factual/discrete) where agreement
across samples filters errors. For open-ended ideation it only dedups, not votes.
**Pros:** it's **self-consistency** (Wang 2022) — proven on reasoning benchmarks
when answers are comparable.
**Cons:** voting breaks down on open-ended generation (the original demo's case);
wasteful for single-answer tasks.
**Efficiency:** user-invoked; cost scales with N agents (use a cheap model for them).
**Maturity:** `Template, untested` — written but not run in a real repo here.
**Evidence:** strong for constrained answers, weak open-ended — see
[catalog/agents.md → Stochastic consensus](agents.md#stochastic-consensus) for cites.
**Template / more:** [tooling/skill-templates/stochastic-consensus.md](../tooling/skill-templates/stochastic-consensus.md).

### Mistake / retro log (a convention, not a skill artifact)
**Use when:** the same mistake or slow path recurs across sessions.
**Pros:** a running doc caught at session start is cheaper than re-paying for the
error every fresh session.
**Cons:** needs discipline to actually update; not a one-shot.
**Efficiency:** near-zero ongoing cost; pure leverage.
**Template / more:** the manual self-improvement loop in
[research/2026-06-28_auto-research-and-harnesses.md](../research/2026-06-28_auto-research-and-harnesses.md);
real instance = `sf-nao-admin/docs/RecurringMistakes.md` + `/retro`.
