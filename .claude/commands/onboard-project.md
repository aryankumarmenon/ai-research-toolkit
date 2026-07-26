---
description: Onboard a new repo into the AI workspace — interview, size (minimal/standard/full), install from tooling/, verify. Pass the target repo's absolute path.
argument-hint: "<absolute path to target repo>"
allowed-tools: Read, Write, Edit, Bash(ls:*), Bash(wc:*), Bash(chmod:*), Bash(date:*), Bash(jq:*)
---

Full rationale and tier criteria → `workflows/onboard-project.md`.
Templates live in `tooling/` — read each template before writing.

## Step 1 — Target

`TARGET = $ARGUMENTS`. If empty or not a directory (`ls "$TARGET"` fails), ask
for the absolute path and stop until given. Do not proceed without a valid path.

`--upgrade` flag: if present, read what's already on disk in the target before
the interview — skip any question whose answer is already encoded in existing
files, and install only the delta.

## Step 2 — Interview (one question at a time)

Ask **one question at a time**, each with a recommended answer. Record the answer
before moving to the next. Eight topics in order:

1. **Git rules** — will Claude make git operations (add/commit/push/stash)?
   Recommended: "No git by Claude."
2. **Visibility** — must `.claude/` stay uncommitted (company-visibility rule)?
   Recommended: check if there's an existing `.gitignore` or `.git/info/exclude`
   that covers `.claude/`.
3. **Tool-name visibility** — must "Claude Code" not appear in committed files?
   Recommended: "Yes" if this is a company/client repo.
4. **Data sensitivity** — any real PII or credentials that agents will read?
   Recommended: "No" unless the repo explicitly handles user data.
5. **Test command** — is there a test command? What is it?
   Recommended: check `package.json`, `Makefile`, `pyproject.toml` first.
6. **Existing docs** — what docs already exist (README, CONTEXT.md, ADRs)?
   Recommended: `ls "$TARGET"` before asking — answer from what's there.
7. **Stack** — language, framework, deploy target?
   Recommended: check file extensions and config files; don't ask what's readable.
8. **Horizon** — how long will this repo be actively worked on with AI?
   Recommended: days/one-off → MINIMAL; weeks with tests → STANDARD; months → FULL.
9. **Project type** — dev, venture/business, or both?
   Recommended: infer from contents — mostly code → dev; strategy/venture docs
   (PRDs, market research, positioning) → venture; both present → both.
   Venture or both → the BUSINESS bundle installs on top of the tier.

## Step 3 — Tier recommendation

State the recommended tier (MINIMAL / STANDARD / FULL) and one sentence why
(cite the answer that drove it — usually horizon or test-suite presence).
If question 9 selected venture/both, also state "+ BUSINESS bundle".
User confirms or overrides. Proceed with the confirmed tier.

## Step 4 — Install

Read each template from this repo's `tooling/` directory (the ai-research
checkout this command ships with) before writing.
Fill every `<…>` placeholder from interview answers. NEVER leave an unfilled
placeholder in a written file.

**All tiers:**
- Write `$TARGET/CLAUDE.md` — pointer-style: one-line purpose, layout from
  existing docs (name the actual files), test command or "none", conventions.
  No rules in CLAUDE.md.
- Write `$TARGET/CLAUDE.local.md` — hard rules FIRST (git rules, deploy rules,
  visibility constraints), then working notes. Remind the user to add this to
  `.git/info/exclude` if `.claude/` must stay uncommitted.
- Install context-capture bundle:
  - Fill and write `STATE-template.md` → `$TARGET/STATE.md`
  - Fill and write `journal-template.md` → `$TARGET/research/journal.md`
    (create `research/` if needed)
  - Copy `load-state.py` → `$TARGET/.claude/hooks/load-state.py`
  - Merge `settings-snippet.json` into `$TARGET/.claude/settings.json`
    (or `settings.local.json` if visibility requires it)
  - Fill and write `sync-context-template.md` →
    `$TARGET/.claude/commands/sync-context.md`

**STANDARD adds:**
- `grilling.md` → `$TARGET/.claude/skills/grilling/SKILL.md` (fill domain)
- `tdd.md` → `$TARGET/.claude/skills/tdd/SKILL.md` (fill test command)
- `handoff.md` → `$TARGET/.claude/skills/handoff/SKILL.md`
- Add haiku subagent pattern to CLAUDE.local.md for most common lookup

**FULL adds (on top of STANDARD):**
- `two-axis-review.md` → `$TARGET/.claude/skills/two-axis-review/SKILL.md`
- `stochastic-consensus.md` → `$TARGET/.claude/skills/stochastic-consensus/SKILL.md`
- `usage-logging-hooks/` bundle → `$TARGET/.claude/hooks/` (all 4 hooks + merge
  their settings block)
- Seed a `/retro-lite` command adapted to this repo

**BUSINESS bundle (on top of any tier, when project type = venture/both):**
- All six agents from `tooling/agent-templates/` →
  `$TARGET/.claude/agents/<name>.md` (fill product name, thesis, target market,
  venture doc path, research notes dir, heuristics, voice notes)
- Flow skills from `tooling/skill-templates/`:
  - `venture-research.md` → `$TARGET/.claude/skills/venture-research/SKILL.md`
  - `venture-plan.md` → `$TARGET/.claude/skills/venture-plan/SKILL.md`
  - `design-critique.md` → `$TARGET/.claude/skills/design-critique/SKILL.md`
- `grilling.md` → `$TARGET/.claude/skills/grilling/SKILL.md` **if not already
  installed** (venture-plan depends on it)
- Append a "Claims discipline" block to `$TARGET/CLAUDE.local.md`:
  every market/competitor/platform claim in venture docs is
  `[verified — source]` or `[hypothesis]`; pasted external AI research
  (Gemini etc.) is unverified input until claim-verifier passes it.

## Step 5 — Verify

Run these checks and report pass/fail for each:

1. `jq . "$TARGET/.claude/settings.json"` (or `settings.local.json`) — must
   parse without error.
2. `grep -r '<' <all files written>` — must return no leftover `<…>` placeholders.
   Expected non-placeholders: `argument-hint` frontmatter brackets and the
   claims-tag format `[verified — <source>]` in BUSINESS-bundle files.
3. STANDARD+: `ls "$TARGET/.claude/skills/"` — confirm expected skill dirs exist.
   BUSINESS bundle: also `ls "$TARGET/.claude/agents/"` — confirm all six agent
   files landed.
4. `ls -la "$TARGET/.claude/hooks/load-state.py"` — confirm file is executable
   (shows `x` bit); if not, `chmod +x "$TARGET/.claude/hooks/load-state.py"`.

## Step 6 — Finish

Print a first-session checklist for the user:

- Open a fresh session in `$TARGET`; confirm STATE.md appears in context preamble
- Run `/sync-context` after first real work session
- Review `CLAUDE.local.md` hard rules — these are the rules that persist
- FULL tier: stdin-smoke-test one hook before the first real session
  (`echo '{}' | python3 .claude/hooks/load-state.py`)

Write the onboarding record into `$TARGET/research/journal.md`:
```
## <date> — onboarded via ai-research

**What we did**
- Onboarded this repo at tier <MINIMAL/STANDARD/FULL> using ai-research tooling.

**What we concluded**
- <one line: the key constraint or decision that drove the tier choice>

**How it's going / next**
- Run /sync-context after the first real session to start the real journal.
```

Also append a mini entry to ai-research's `research/journal.md`:
`## <date> — onboarded <name>` + one line noting tier and path.
