# Workflow: Onboard a New Project

Every new repo triggers the same six questions. Without front-loading them, you
answer them piecemeal — once when writing the first CLAUDE.md, again when you
hit a git-op permission prompt, again when a hook silently does nothing. Front-
load them once, size the install to the answers, and never re-derive them.

The risk on the other side is over-installing. Oversized instruction files
actively harm: the `sf-nao-admin` workspace refactor found ~18.5k tokens of fixed
overhead from triple-stated rules and instruction files that hadn't been pruned
as the repo grew — halving that overhead roughly doubled useful-context per
session (→ `improvements/nao-pipeline-improvements.md` §E–H). Start minimal.

```
interview → tier → install from tooling/ → verify → record
```

---

## The interview (one question at a time)

Ask these in order, one at a time with a recommended answer each time (grilling
discipline — never batch). Each answer gates a consequence:

| Question | Consequence |
|---|---|
| **Git rules** — will Claude make git operations in this repo? | "No git by Claude" → hard rule #1, goes into CLAUDE.local.md, `allowed-tools` everywhere strips `Bash(git:*)` |
| **Visibility** — must `.claude/` stay uncommitted? | Yes → use `settings.local.json` only; exclude `.claude/` in `.git/info/exclude` |
| **Tool-name visibility** — must Claude Code not appear in committed files? | Yes → generic hook/skill names, no `Claude Code` mentions in committed docs |
| **Data sensitivity** — any real PII or credentials in the repo? | PII present → skip usage-logging hooks (no ledger of file reads) |
| **Test command** — is there a test command? | None → skip tdd skill; note "no tests" in CLAUDE.md |
| **Existing docs** — what docs already exist? | List → seed CLAUDE.md layout from them; don't re-document what's there |
| **Stack** — language, framework, deploy target? | → model tiering in skills (haiku for mechanical, inherit for judgment) |
| **Horizon** — how long will this repo be active? | Days/exploratory → MINIMAL; weeks with tests → STANDARD; months → FULL |
| **Project type** — dev, venture/business, or both? | Venture/both → BUSINESS bundle installs on top of the tier (see below) |

---

## The three tiers

### MINIMAL — any new, exploratory, or strict-visibility repo

Install when: the repo is new or experimental, or company-visibility constraints
make heavy `.claude/` config risky.

- CLAUDE.md seed: short pointer-style file — purpose (one line), layout derived
  from existing docs (if any), conventions (test command or "none"), link to any
  standards doc. No rules in CLAUDE.md.
- CLAUDE.local.md: hard-rules-first layout — git rules, deploy rules, visibility
  constraints at the very top, before any "how to work" notes. This is the file
  that never gets committed.
- context-capture bundle (`tooling/context-capture/`): STATE.md + journal +
  load-state.py SessionStart hook + /sync-context command.

### STANDARD — active dev, test suite exists, weeks+ horizon

Everything in MINIMAL, plus:

- `grilling.md` skill template (fitted with the repo's domain context).
- `tdd.md` skill template (with the real test command substituted).
- `handoff.md` skill template.
- A cheap exploration subagent entry in CLAUDE.local.md: one haiku subagent
  pattern for the most common mechanical lookup in this repo.

Tier up from MINIMAL when: you're starting real feature work with a test suite,
and sessions will recur over weeks.

### FULL — months-horizon, learning loop earns its cost

Everything in STANDARD, plus:

- `two-axis-review.md` skill template (Standards + Spec parallel subagents).
- `stochastic-consensus.md` skill template (for high-stakes design decisions).
- `usage-logging-hooks/` bundle: append-only usage ledger + context-hygiene nudge.
- A `/retro-lite`-style command seeded for this repo (promote pending-lessons
  human-gated, y/n per item).

Tier up from STANDARD when: sessions are frequent, decisions compound, and you
want the learning loop to surface patterns across sessions.

**Tier-up (`--upgrade`):** re-run `/onboard-project` against the same repo later.
The command reads what's already on disk, skips interview questions already
answered, and installs only the delta.

### BUSINESS bundle — an axis, not a tier

Project type (question 9) is orthogonal to size: a venture repo can be MINIMAL
(a folder of strategy docs) or FULL (a product being built). When the answer is
venture/both, install on top of whatever tier was chosen:

- The six role agents from `tooling/agent-templates/` (ceo-strategist,
  product-manager, marketing-growth, ux-designer, market-researcher,
  claim-verifier) → `.claude/agents/`.
- The three flow skills: `venture-research`, `venture-plan`, `design-critique`
  → `.claude/skills/`. Plus `grilling` if the tier didn't already bring it
  (venture-plan's step 2 depends on it).
- A "Claims discipline" hard-rule block in CLAUDE.local.md: venture-doc claims
  are `[verified — source]` or `[hypothesis]`, and external AI research pastes
  stay unverified input until claim-verifier passes them.

Route and decision menu: [venture-pipeline.md](venture-pipeline.md) ·
[../catalog/business-agents.md](../catalog/business-agents.md).

---

## Portability invariant

Everything installed comes from `tooling/`. No file is written with hardcoded
paths or project-specific logic inside it — only filled `<…>` placeholders and
the real project name where the template said `<project-name>`. This means the
templates stay the source of truth; the project copy is the deployment. When a
template proves itself (or a bug is found), fold improvements back into `tooling/`
so the next onboarding benefits.

---

## Verification

After installing, confirm:

- `jq . <project>/.claude/settings.json` (or `settings.local.json`) parses
  without error.
- `grep -r '<' <installed files>` returns no leftover `<…>` placeholders.
- For STANDARD+: `ls <project>/.claude/skills/` shows the expected skill dirs.
- BUSINESS bundle: `ls <project>/.claude/agents/` shows all six agent files.
- `chmod +x` on `load-state.py` is confirmed (the hook silently does nothing if
  not executable).

---

## Post-onboarding recording

1. Open a fresh session in the target repo and confirm STATE.md auto-loads (it
   appears in the context preamble, not as a file read).
2. Run `/sync-context` after the first real work session to write the first
   real journal entry.
3. Review CLAUDE.local.md hard rules — these are the only rules that reliably
   persist across contexts; make sure they match what you actually decided.
4. FULL tier only: stdin-smoke-test one hook before relying on it in a real
   session (`echo '{}' | python3 .claude/hooks/load-state.py`).
5. Append a one-line record to `ai-research`'s `research/journal.md` noting
   what was onboarded and when — so the ai-research STATE.md stays honest about
   which repos are under active AI management.

---

## Quick checklist

- [ ] Interviewed one question at a time; all eight topics answered
- [ ] Tier chosen (MINIMAL / STANDARD / FULL) with one stated reason
- [ ] Installed from `tooling/`; no unfilled `<…>` placeholders
- [ ] Hard rules are the FIRST section of CLAUDE.local.md
- [ ] CLAUDE.md seed is pointer-style (short; no duplicated rules)
- [ ] settings.json (or .local) parses with `jq`
- [ ] load-state.py is executable; STATE.md is filled
- [ ] ai-research journal updated with onboarding record
