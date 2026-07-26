# Guide: Writing Great Skills

How to author a skill that behaves *predictably*. Distilled from Pocock's
`writing-great-skills` (vendored at
[`references/mattpocock-skills/skills/productivity/writing-great-skills/`](../references/mattpocock-skills/skills/productivity/writing-great-skills/SKILL.md)).

> **Authoritative backing:** the canonical `SKILL.md` frontmatter/structure rules
> are Anthropic's now-vendored [Agent Skills spec](../references/anthropic-skills/spec/agent-skills-spec.md)
> (+ official [`template/`](../references/anthropic-skills/template/)). When you're
> about to write one, the meta-skill [`skill-creator`](../references/anthropic-skills/skills/skill-creator/)
> and the plugin-dev [authoring skills](../references/claude-code-plugins/plugins/plugin-dev/skills/)
> are the official worked references. Pocock below is the *discipline*; the spec is
> the *grammar* it must fit.

## The root virtue: predictability

> A skill exists to wrangle determinism out of a stochastic system.

Predictability means the agent takes the same **process** every run — *not* that
it produces identical output. Every lever below serves that one goal.

## The two costs you're always spending

Every line and every skill spends one of two budgets:

- **Context load** — tokens sitting in the window every turn (a model-invoked
  skill's description; everything in `SKILL.md` once invoked).
- **Cognitive load** — *your* memory: a user-invoked skill has zero context load
  but you have to remember it exists.

Cut by invocation (model vs user) and split skills only when a cut *earns* one of
these costs back.

## Writing the description (model-invoked)

The description does two jobs — say what the skill is, and list the **branches**
that trigger it. Every word is context load, so prune it harder than the body:

- **Front-load the leading word** — the description is where invocation work happens.
- **One trigger per branch.** Synonyms renaming a single branch are duplication —
  "build features using TDD … asks for test-first development" is one branch
  written twice. Collapse.
- **Cut identity already in the body.** Keep description to triggers + any "when
  another skill needs…" reach clause.

(User-invoked: strip triggers; the description becomes a one-line human summary.)

## Information hierarchy — the ladder

A skill mixes two content types, **steps** (ordered actions) and **reference**
(facts/rules consulted on demand), placed on a ladder by how immediately the agent
needs them:

1. **In-skill step** — an ordered action in `SKILL.md`. Each ends on a
   **completion criterion**: a *checkable* condition (can the agent tell done from
   not-done?) and, where it matters, *exhaustive* ("every modified model
   accounted for", not "produce a change list"). A vague criterion invites
   premature completion.
2. **In-skill reference** — a definition/rule/fact in `SKILL.md`, consulted on
   demand. Often a flat peer-set (every review rule on one rung) — fine, not a smell.
3. **External reference** — pushed into a separate file, reached by a **context
   pointer**, loaded only when the pointer fires.

**Progressive disclosure** is the move down the ladder so the top stays legible.
**Branching is the disclosure test:** inline what *every* branch needs; push
behind a pointer what only *some* branches reach. A context pointer's *wording*
(not its target) decides how reliably the agent follows it.

**Co-location:** once something's on a rung, keep its definition, rules, and
caveats under one heading so reading one part brings its neighbours.

## When to split a skill

- **By invocation** — split off a model-invoked skill when it has a distinct
  leading word that should trigger it, or another skill must reach it. You pay
  context load for the new always-loaded description, so the independent reach
  must be worth it.
- **By sequence** — split a run of steps when the steps still ahead tempt the
  agent to rush the one in front (premature completion). Hiding them encourages
  more legwork on the current task.

## Pruning

- **Single source of truth** — each meaning in exactly one place (one-edit changes).
- **Relevance** — does each line still bear on what the skill does?
- **No-ops** — hunt sentence by sentence: does this change behavior vs the
  default? If not, delete the whole sentence (don't trim words). Be aggressive.

## Leading words

A **leading word** is a compact concept already in the model's pretraining
(*lesson*, *fog of war*, *tracer bullet*, *tight*, *red*) that anchors a whole
region of behavior in the fewest tokens by recruiting priors the model holds.

- In the **body** it anchors execution (same behavior every time the word appears).
- In the **description** it anchors invocation (when the same word lives in your
  prompts/docs/code, the agent links that shared language to the skill).

Hunt for restatements to collapse: "fast, deterministic, low-overhead" → a
*tight* loop; "a loop you believe in" → the loop goes *red*. You win twice: fewer
tokens *and* a sharper hook. Assume every skill carries restatements a leading
word would retire.

## Failure modes (diagnose a misbehaving skill)

| Symptom | Name | Fix |
|---|---|---|
| Step ends before it's done, attention slipping to "being done" | **Premature completion** | Sharpen the completion criterion first; only if irreducibly fuzzy *and* you see the rush, split to hide the post-completion steps |
| Same meaning in more than one place | **Duplication** | Collapse to single source of truth |
| Stale layers that accreted because adding feels safe | **Sediment** | A pruning discipline |
| Too long even though every line is live | **Sprawl** | Disclose reference behind pointers; split by branch/sequence |
| A line the model already obeys by default | **No-op** | Delete; a weak leading word (*be thorough*) is a no-op — use a stronger one (*relentless*) |

## A minimal skeleton

```markdown
---
name: my-skill
description: <leading-word-first>. Use when the user <branch 1>, <branch 2>.
# disable-model-invocation: true   # add for user-invoked (orchestrators)
# argument-hint: "<arg>"
# allowed-tools: Read, Grep, Glob
---

# My Skill

<one line of identity if not already in the description>

## Process
1. <step> — done when <checkable, exhaustive criterion>.
2. <step> — done when …

## <Reference heading>
<flat rules/definitions consulted on demand; co-located under their heading>
```

See [tooling/skill-templates/](../tooling/skill-templates/) for ready-to-copy
templates following these rules.

---

## Frontmatter discipline levers

Every skill YAML block supports these fields. Most are optional, but each is a
real lever — not decoration.

```yaml
---
name: my-skill                          # required; identifier used in /skill-name
description: <trigger text>             # required; model reads this every turn
disable-model-invocation: true          # add for user-invoked skills (/commands,
                                        # orchestrators). Prevents auto-trigger.
argument-hint: "<what to pass>"         # shown to the user when they invoke the
                                        # skill; guides the $ARGUMENTS value
allowed-tools: Read, Grep, Glob         # whitelist — skill can ONLY call these
                                        # tools; everything else is blocked.
                                        # Omit to inherit the session's full set.
model: haiku                            # pin to a cheaper/faster model for
                                        # mechanical skills; omit to inherit the
                                        # session model for judgment-heavy ones.
---
```

**`allowed-tools`** is a security and discipline lever, not just documentation.
When set, Claude cannot call any tool not in the list — even if the session
normally permits it. Use it any time a skill has no reason to write files, run
bash, or call the network: `Read, Grep, Glob` for read-only analysis; add
`Write, Edit` only if the skill's job is to produce files. A tightly scoped
skill is also cheaper and harder to misuse.

**`model`** is a cost-tiering lever. Mechanical skills (doc-syncing, linting,
handoff doc generation) can be pinned to `haiku`; judgment-heavy skills
(grilling, TDD, review) should inherit the session model so they get the
capability they need. Pinning the wrong skill to haiku costs correctness;
leaving mechanical skills on the session model wastes budget.

**`disable-model-invocation`** must be set on any skill the user calls by name
(`/skill-name`) rather than relying on model auto-detection. Without it, the
model may also trigger the skill autonomously, creating double-invocations.

**`argument-hint`** is shown inline when the user types `/skill-name` — phrase
it as a cue, e.g. `"feature name or file path"`.

Authoritative field set: [`references/anthropic-skills/spec/agent-skills-spec.md`](../references/anthropic-skills/spec/agent-skills-spec.md)
and the official template at [`references/anthropic-skills/template/SKILL.md`](../references/anthropic-skills/template/SKILL.md).

---

## Progressive disclosure and bundled resources

A skill's content loads in three levels. The discipline is to put each piece on
the *lowest* level that still reaches it reliably.

**Level 1 — Metadata (name + description).** Always in context, every turn, ~100
words. The model reads this to decide whether to invoke the skill. Cost is
constant, so keep it tight — only trigger clauses and the "when another skill
needs…" reach clause.

**Level 2 — SKILL.md body.** Loaded once, when the skill triggers. Target under
500 lines. This is where ordered steps, completion criteria, and inline reference
sections live. If you are approaching 500 lines, the skill is carrying content
that belongs at Level 3.

**Level 3 — Bundled resources.** Loaded *on demand*, via explicit pointers in the
body. Three sub-buckets:

```
skill-name/
├── SKILL.md
└── (optional)
    ├── scripts/     – executable code run without loading into context
    ├── references/  – docs loaded when a step needs them
    └── assets/      – output files (templates, icons) used but not read
```

**Writing "load X when Y" pointers.** The pointer's wording determines how
reliably the model follows it — be specific:

> "Read `references/api-schema.md` before Step 3 if the target file is a selector."

> "If the output is a `.docx`, run `scripts/build_docx.py` instead of writing
> Python inline."

Vague pointers ("see references/ for more") get ignored. Specific ones fire
reliably.

**When to add a Level 3 layer.** Add `references/` or `scripts/` when:
- A reference section in SKILL.md exceeds ~100 lines but is only needed on some
  branches (push it behind a pointer).
- The same helper script was rewritten in multiple test runs (bundle it once).
- The skill supports multiple domains (e.g. AWS / GCP / Azure) — one reference
  file per domain, SKILL.md only loads the relevant one.

**When NOT to add a layer.** If every branch of the skill needs the content,
keep it in Level 2 — a pointer that always fires just adds a read step with no
disclosure benefit.

Authoritative source: [`references/anthropic-skills/skills/skill-creator/SKILL.md`](../references/anthropic-skills/skills/skill-creator/SKILL.md)
§ "Progressive Disclosure"; plugin-dev skill at
[`references/claude-code-plugins/plugins/plugin-dev/skills/skill-development/SKILL.md`](../references/claude-code-plugins/plugins/plugin-dev/skills/skill-development/SKILL.md)
§ "Progressive Disclosure Design Principle".

---

## Skill-testing loop

A skill is only as good as its measured delta over no-skill behavior. The
official loop from `skill-creator`:

**1. Dual-baseline evaluation.** For each test prompt, spawn two subagents in the
*same turn*: one with the skill, one without (or against the prior skill version
when improving). Do not run with-skill first and baseline later — launch both in
parallel so they finish together and you get a clean comparison. Save outputs to
`<skill-name>-workspace/iteration-N/eval-<ID>/{with_skill,without_skill}/outputs/`.

**2. `benchmark.json`.** After grading, aggregate into a benchmark with per-config
`pass_rate`, `time_ms`, and `tokens`. The aggregation script in `skill-creator`
produces this automatically; if building manually, follow the schema in
`references/schemas.md` inside skill-creator. The benchmark reveals three things
the qualitative review misses: non-discriminating assertions (always pass,
whether skill is present or not), high-variance evals (flaky), and time/token
tradeoffs.

**3. Repeated-helper-script detection.** Read the transcripts of all test runs.
If every run independently wrote the same helper script (e.g. `build_chart.py`),
that script belongs in `scripts/` — bundle it once, pointer it from SKILL.md.
This is the signal to add a Level 3 layer (see above).

**Improving the loop iteratively.** After the user reviews the viewer output,
rewrite the skill, re-run into `iteration-N+1/`, pass `--previous-workspace`
so the viewer shows side-by-side diffs. Stop when pass_rate plateaus or the user
is satisfied.

Full procedure and grader/analyzer agents:
[`references/anthropic-skills/skills/skill-creator/SKILL.md`](../references/anthropic-skills/skills/skill-creator/SKILL.md)
§ "Running and evaluating test cases".

---

## Router-skill pattern

When a user-invoked skill collection grows large enough that users struggle to
remember which skill to call, add a **router skill**: a lightweight skill whose
only job is to list what's available and map each trigger phrase to the right
skill.

```yaml
---
name: help
description: <one-line; user-invoked>
disable-model-invocation: true
allowed-tools: Read
---
```

The body is a table: trigger phrase → skill name → one-line description. The
router carries no procedure of its own — it delegates immediately. This keeps
each specialist skill's description clean (no "also see X, Y, Z" clutter) and
gives the user a single `/help` entry point.

Add a router when: (a) you have 6+ user-invoked skills and users are calling the
wrong one, or (b) a model-invoked skill's description is getting long trying to
distinguish itself from siblings.

Note (Claude Code v2.1.199): stacked invocations — `/skill-a /skill-b task` —
now load all leading skills (up to 5), so composing skills at runtime no longer
needs a router. A router earns its place only for the discovery/memory problem
above, not for composition.
