# Agent Harnesses & Auto-Research

Three connected mental models from Nick Saraev's *"Claude Code Advanced Full
Course (3hr)"* — the advanced follow-up to his 4hr course already cited in
[references/README.md](../references/README.md). Kept here because none of this
existed in the repo yet; the CLAUDE.md-compression basics from the same video
are deliberately **not** re-extracted (already covered in
[context-and-subagents.md](../guides/context-and-subagents.md) and
[writing-skills.md](../guides/writing-skills.md)).

---

## 1. What an "agent harness" actually is

> A harness is **everything that wraps the LLM but is not the LLM**.

The model is text-in/text-out and can't touch the world. The harness is what
turns that into something that does economically valuable work: the system
prompt, the tool definitions (bash, grep, read/write memory), the hooks, and
the parameters around it (auto-compact threshold, turn limits, token budgets).
Claude Code *is* a harness around the Claude model. Analogy: same gunpowder
(the model), but the barrel (the harness) decides how far the bullet goes —
it narrows the model's many possible directions into useful ones.

**Why it matters in practice:** "it's not the harness that makes the
intelligence" — the model is already strong out of the box. So don't over-build
harness machinery (elaborate CLAUDE.md, custom SDKs) before you've felt where
the vanilla agent actually falls short. Harnesses also differ on *safety*: some
will happily run `sudo rm -rf` or route around a blocked command ("same effect,
less policy friction") if a prompt-injected page tells them to. Permission mode
is a harness property, not a model one.

---

## 2. The manual self-improvement loop

The everyday version of "tuning the harness." A tight inner loop plus an
occasional outer loop:

**Inner loop (per task):** plan → implement → *ask the agent to critique its
own execution* → fold the lesson into CLAUDE.md → repeat.
- The high-leverage move is one question after a task completes:
  **"How could you have arrived at this and done what I asked faster, and for
  fewer tokens?"** It surfaces concrete waste — e.g. *"I made 20 sequential
  edit calls; I should have read the file and done a single `Write` to replace
  it."* Save that as a user-preference line.
- A standing **meta-prompt** in CLAUDE.md: *"When you make a mistake, append it
  to a running 'lab notes — what not to do' log."* The file becomes an
  experimenter's notebook of failures + learnings for the next session.

**Outer loop (every few sessions):** run a command that spawns subagents across
your whole conversation history (Saraev's `/insights`-style pass), spot
cross-session patterns, and promote them from the project CLAUDE.md to the
**global** CLAUDE.md. Global is where identity, goals, and reasoning
preferences live so every session has them — e.g. *"money is not my bottleneck;
trade my money for my time"* changes what the agent recommends.

> This is the same shape as the `sf-nao-admin` `RecurringMistakes.md` +
> `/retro` system in [improvements/nao-pipeline-improvements.md](../improvements/nao-pipeline-improvements.md)
> — Saraev's loop is the general statement of why that pattern works.

---

## 3. Auto-research — the loop, fully automated

When you remove the human from the loop entirely, the self-improvement loop
becomes **auto-research** (Andrej Karpathy's framing; repo:
`github.com/karpathy/autoresearch`). The agent runs the
hypothesis → change → assess → keep-or-discard → log cycle on its own, hundreds
of times.

**The three prerequisites** (if you can't name all three, it's not an
auto-research problem):
1. **A metric** — objective and standardized (e.g. Google Lighthouse score).
2. **A change method** — a lever that moves the metric (e.g. edit the website
   code).
3. **An assessment** — a way to score the change (e.g. re-run Lighthouse).

**The hidden fourth requirement: speed.** Change + assessment must each be
fast (~30s) so the loop runs ~60×/hour ≈ 1,440×/day. The payoff is compounding:
if even 2% of changes help by ~1% each, that's `1.01^30 ≈ 34%`/day — and it
keeps climbing. A slow loop (1hr/iteration) still beats a human, but you lose
the steep curve.

**Structure** (from the repo): `program.md` tells the agent what it may change,
the loop instructions, and where to append the log; the target artifact (a
website, a service, a prompt) is what gets mutated. Constrain the change space
explicitly — e.g. *"screenshot must stay pixel-perfect vs. the original"* keeps
a perf run from altering the visible design.

**The spectrum of human involvement:**
`vibe coding` (human prompts, AI writes, human reviews) →
`agentic engineering` (human directs orchestrated agents) →
`auto-research` (human sets goal + metric + assessment; agent self-directs).
Each step removes the human further from the work.

**It works on more than websites.** Tobi Lütke ran it on Shopify's Liquid
codebase: ~53% faster parse+render, ~61% fewer object allocations. Anyone with
a metric + lever + fast assessment + enough data can use it: SaaS front/back-end
latency, customer-support prompt tuning, cold email, ad creative, copy,
conversion rate. Big labs already do this internally; the repo just democratizes
it.

---

## Takeaways

- Don't build harness machinery before you've felt the vanilla agent's limits.
- After a task, ask *"how could you have done that faster / for fewer tokens?"*
  and log the answer — that single question is most of the manual loop.
- Reach for auto-research only when you can name a metric, a fast change method,
  and a fast assessment. Speed of the loop, not cleverness, is what compounds.
