# catalog/

A **decision catalog** of agent and skill patterns — pick one by requirement.
Each entry answers: *what is it, when does it fit, what are the pros/cons, and
what does it cost* (tokens / model tier / speed). It does **not** hold the
deployable artifact — when an entry has a ready template, it links to
[`tooling/`](../tooling/).

## How this differs from the neighbours (so it doesn't rot into a duplicate)

| Folder | Question it answers |
|---|---|
| **`catalog/`** (here) | *Which* pattern do I want, and what does it cost? — comparative, decision-first |
| [`tooling/`](../tooling/) | Give me the copy-paste artifact for the one I chose |
| [`guides/`](../guides/) | How does the underlying mechanism actually work |

If you find yourself pasting code here, it belongs in `tooling/`. If you're
re-explaining how subagents/skills work, it belongs in `guides/`. Keep entries
here to *idea + trade-offs + efficiency + a link*.

## Contents

- [agents.md](agents.md) — subagent / multi-agent patterns (roster + parallel patterns)
- [skills.md](skills.md) — skill patterns (the repeatable-procedure artifacts)
- [business-agents.md](business-agents.md) — the venture/business role-agent family (CEO, PM, marketing, UX, research, verification) + its three flows

## Entry format

Each entry is short and uniform:

```
### <Pattern name>
**Use when:** <the requirement that selects this>
**Pros:** <what it buys you>
**Cons:** <the cost / failure mode>
**Efficiency:** <model tier · token cost · speed>
**Maturity:** <have *I* run it — only present when there's a caveat, see below>
**Evidence:** <has the *field* validated it — only present when researched>
**Template / more:** <link to tooling/ or guides/, if any>
```

Keep it scannable — the value is choosing fast, not reading prose. When a pattern
graduates to a real, reusable artifact, add the template to `tooling/` and link it
from here rather than fattening the entry.

## Maturity vs. Evidence — know what you're in for

Two independent axes, because "I've run it" and "the field has validated it" are
different questions (and the earlier ones in this catalog were seeded from a
single practitioner video):

**Maturity = have *I* run it in this setup.** No line = proven here (real
`sf-nao-admin`/`ai-research` work, or template-backed and run). Two caveats:
- **`Template, untested`** — artifact exists but hasn't run in a real repo here.
  Treat as a draft; expect to debug on first use.
- **`Conceptual`** — idea + rationale only, no worked example here. You'll design
  the specifics; don't trust the efficiency numbers until you've measured them.

**Evidence = what the wider field reports** (added after a research pass, with
links). Present only where checked. This is where external grounding — or
external *doubt* — gets recorded, even for a pattern I haven't personally run.
A pattern can be `Conceptual` for me yet have strong field evidence (or vice
versa) — read both lines.
