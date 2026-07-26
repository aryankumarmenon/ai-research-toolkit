# Guide: Skills vs Commands vs Agents vs Hooks vs MCP

Which extension mechanism to use, and how each is wired. Sourced from
shanraisshan's `claude-code-best-practice` (the mechanics) and Pocock's
invocation model (the discipline).

## The one-line decision

| If you want… | Use a… | Lives in |
|---|---|---|
| A repeatable *procedure* you (or the agent) invoke | **Skill** | `.claude/skills/<name>/SKILL.md` |
| A simple prompt template you type | **Command** | `.claude/commands/<name>.md` |
| Isolated context / a cheaper model / parallelism | **Subagent** | `.claude/agents/<name>.md` |
| *Deterministic* automated behavior on an event | **Hook** | `.claude/settings.json` + a script |
| Someone else's external tools | **MCP server** | `.mcp.json` |
| Static knowledge always in context | **Memory** (`CLAUDE.md` / rules) | `CLAUDE.md`, `.claude/rules/` |

The litmus that trips people up: **"from now on, whenever X, do Y" is a hook, not
a memory.** The harness executes hooks; the model executes instructions. A
preference in `CLAUDE.md` is advisory and can be missed; a hook is guaranteed.

---

## Skills

A skill packages a procedure (a `SKILL.md` with frontmatter + body, optionally
with scripts/reference files alongside). Only the **frontmatter** (name +
description) loads at rest — ~60 tokens each — so a dozen skills is cheap. The
body loads only when invoked.

**The invocation axis (Pocock):**
- **User-invoked** — `disable-model-invocation: true`. Only the human typing its
  name reaches it; no other skill can. Description is human-facing (no trigger
  lists). **Zero context load**, but *you* must remember it exists. Job: orchestrate.
- **Model-invoked** — omit that flag. Model *or* user reaches it. Description is
  model-facing with rich triggers ("Use when the user wants…, mentions…").
  **Costs context load** every turn. Job: reusable discipline the agent can fire.

Test for keeping it model-invoked: *could the model usefully reach for this on its
own?* Reuse is the reason to *extract* a skill, not the test for invocation.

When user-invoked skills outgrow your memory, add a **router skill** (one
user-invoked skill that names the others) — that's what Pocock's `ask-matt` is.

Frontmatter fields seen in practice: `name`, `description`, `disable-model-invocation`,
`argument-hint`, `allowed-tools`, `model`.

**Real-world flip, Claude Code ≥v2.1.215:** Anthropic's own bundled `/verify` and
`/code-review` skills moved from model-invoked to user-invoked-only — Claude no
longer runs them automatically; you must type the command. Even the vendor's own
skills get pulled back to explicit invocation once auto-firing on every plausible
turn stops paying for its context cost. (Our own review templates —
[two-axis-review.md](../tooling/skill-templates/two-axis-review.md) — already ship
with `disable-model-invocation: true`, so this didn't change anything for us; it's
corroborating evidence for the axis test above, not a template update.)

→ Authoring details: [writing-skills.md](writing-skills.md).

## Commands

A lighter-weight `.md` prompt template invoked as `/name`, with `$ARGUMENTS`
substitution and the same frontmatter (`description`, `argument-hint`,
`allowed-tools`). In current Claude Code the line between a user-invoked skill and
a command is thin — my NAO pipeline is built as **commands** (`/grill-me`,
`/write-prd`, …); Pocock's equivalents are **user-invoked skills**. Functionally
similar; skills get a folder (room for reference files/scripts), commands are a
single file. Reach for a skill when the procedure needs companion files; a command
when it's a self-contained prompt.

## Subagents (agents)

A `.claude/agents/<name>.md` defines a named subagent: `name`, `description`
(with "use PROACTIVELY when…" for auto-delegation), `tools` (restrict to what it
needs), `model` (cheaper models for grunt work). It runs in its own context and
returns a summary.

Two reasons to use one — **volume isolation** (research/search) and **bias
isolation** (review/QA). Keep their task definitions *simple* (they're dumber than
the parent). My NAO `codebase-explorer` and `nao-server-reference` are both
read-only, haiku, single-purpose lookup agents — a good template.

→ Economics + roster: [context-and-subagents.md](context-and-subagents.md).

## Hooks

Commands the **harness** runs on lifecycle events (PreToolUse, PostToolUse, Stop,
Notification, …), configured in `settings.json` with a `matcher` (e.g. `Bash`) and
a `command`. Because the harness — not the model — runs them, they're the only way
to get *guaranteed* behavior.

**Canonical example — git guardrails** (Pocock's `git-guardrails-claude-code`): a
PreToolUse hook matching `Bash` that inspects the command and exits non-zero
(blocking it) on `git push`, `git reset --hard`, `git clean -f`, `git branch -D`,
`git checkout .`. Verify with:
```bash
echo '{"tool_input":{"command":"git push origin main"}}' | ./block-dangerous-git.sh
# expect exit 2 + a BLOCKED message on stderr
```
Other uses: format-on-save (PostToolUse), play a sound on Stop, inject project
context on session start.

**The full event surface (~30 events).** Beyond the common few, Claude Code fires
hooks at many lifecycle points — `PreToolUse`, `PostToolUse`, `PostToolUseFailure`,
`PermissionRequest`, `PermissionDenied` (return `{retry: true}` to let the model
retry), `UserPromptSubmit`, `UserPromptExpansion` (matches on `command_name`),
`PreCompact`/`PostCompact`, `SubagentStart`/`SubagentStop`, `PostToolBatch`,
`Notification` (since v2.1.198 also fires for background agents with
`agent_needs_input` / `agent_completed` — react to agent lifecycle without polling),
`MessageDisplay` (display-only, can rewrite on-screen text), `SessionStart`/`End`,
`Setup` (via `--init`), plus agent-frontmatter-scoped hooks. The full table with
payload fields is in the vendored
[best-practice `.claude/hooks/HOOKS-README.md`](../references/claude-code-best-practice/dot-claude/hooks/HOOKS-README.md);
the worked dispatcher is
[`.claude/hooks/scripts/hooks.py`](../references/claude-code-best-practice/dot-claude/hooks/scripts/hooks.py)
with per-event toggles in
[`hooks-config.json`](../references/claude-code-best-practice/dot-claude/hooks/config/hooks-config.json).
Note `disableAllHooks` / `.local.json` overrides let each dev opt out without
touching shared settings.

> This is the right home for the NAO "company-visibility" rule — a hook that
> keeps tool-specific names out of committed files, rather than relying on the
> model remembering.

**Verified hook mechanics (2026-07-04**, against
[code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks)**):**

- **UserPromptSubmit's prompt field is `prompt`.** Parsing a wrong field (e.g.
  `.user_message`) fails *silently* — the hook runs, matches nothing, logs
  nothing, and looks installed. A hook that has never fired is a bug signal,
  not proof of quiet behavior. `UserPromptExpansion` is real and fires when a
  typed `/command` expands; its payload names aren't fully documented — use
  defensive jq fallbacks (`.command_name // .command // empty`).
- **PreToolUse denies with JSON, not just exit codes:**
  `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":
  "deny","permissionDecisionReason":"…"}}` on stdout (also `allow`/`ask`).
- **PostToolUse can REPLACE the tool result the model sees** via
  `hookSpecificOutput.updatedToolOutput` — this makes true output filtering
  (e.g. verbose test runs → failures + summary) possible, not just additive
  `additionalContext` notes. The hook must be synchronous to do it.
- **`Stop` fires at every response end, not session end.** A Stop warning
  without state fires every turn (observed: 11/17 warns were repeats). Two
  patterns fix it: a **sentinel file** (warn once per dirty period, delete the
  sentinel when the condition clears so it re-arms) and a **byte-offset
  marker** (a Stop hook that scans a ledger stores the last-processed offset
  and reads only new bytes — exactly-once, per-iteration processing).
  `SessionEnd` exists too (matchers = end reason) but can't talk back to the
  model.
- Still true: hooks never see real token/context %; mechanical proxies only.

## MCP servers

External tool providers wired via `.mcp.json`. Convenient, but their tool
*schemas* load into context — a bloated server can eat 10–20% of the window
instantly (more than all your skills combined). Be selective; audit with
`/context`. **Pattern:** prototype with an MCP to prove something's possible, then
*convert it to a skill* (find the underlying API, write a script) for the
token-efficient repeatable version. Modern clients mitigate bloat with on-demand
tool search when MCP descriptions exceed ~10% of the window — but don't rely on it.
Mechanics + a worked file:
[best-practice/claude-mcp.md](../references/claude-code-best-practice/best-practice/claude-mcp.md),
[.mcp.json](../references/claude-code-best-practice/dot-mcp.json).

## Memory / rules

`CLAUDE.md` (project) and `~/.claude/CLAUDE.md` (global) and `.claude/rules/*.md`
are injected into context. Static *knowledge* and *advisory* preferences live
here; *automated actions* do not (use a hook). Keep them tight — see
[context-and-subagents.md](context-and-subagents.md#instruction-files).
Deep dives:
[best-practice/claude-memory.md](../references/claude-code-best-practice/best-practice/claude-memory.md),
[reports/claude-global-vs-project-settings.md](../references/claude-code-best-practice/reports/claude-global-vs-project-settings.md),
and the agent-written-memory pattern in
[.claude/agent-memory/](../references/claude-code-best-practice/dot-claude/agent-memory/).

## Settings & permissions

`.claude/settings.json` holds permissions, env vars, model config, status line,
and hook wiring; `settings.local.json` is git-ignored per-dev overrides.
Worked example + the precedence rules (enterprise → global → project → local):
[best-practice/claude-settings.md](../references/claude-code-best-practice/best-practice/claude-settings.md),
[.claude/settings.json](../references/claude-code-best-practice/dot-claude/settings.json).

## Orchestration vs agent-teams

Two ways to put subagents to work — don't confuse them:

- **Orchestration** — *one* command drives subagents in sequence/fan-out and
  synthesizes their results (a controlled pipeline). This is the pattern behind a
  two-axis review or a codebase-health command. Worked example:
  [orchestration-workflow.md](../references/claude-code-best-practice/orchestration-workflow/orchestration-workflow.md),
  [weather-orchestrator.md](../references/claude-code-best-practice/dot-claude/commands/weather-orchestrator.md).
- **Agent teams** — many full agent instances running in parallel (experimental;
  `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`). Powerful for massive parallel
  research/review, but ~7× token cost — see the skepticism in
  [context-and-subagents.md](context-and-subagents.md). Worked example:
  [agent-teams/](../references/claude-code-best-practice/agent-teams/).

For a fuller multi-agent dev pipeline (research→plan→implement with role agents),
see the vendored **RPI workflow**:
[development-workflows/rpi/rpi-workflow.md](../references/claude-code-best-practice/development-workflows/rpi/rpi-workflow.md).

---

## Worked example: turning a need into the right mechanism

> "I want every new Apex class to get a JSDoc header, and I keep forgetting to
> check existing code before writing new helpers."

- "Check existing code before writing" → a **subagent** (`codebase-explorer`)
  invoked from the align/implement steps. ✅ (built)
- "Every new class gets a JSDoc header" → if it's *advice*, a line in a **rule**
  file; if it must be *guaranteed*, a **hook** (PostToolUse on Write/Edit that
  lints the file). The recurring-mistake framing ("I keep forgetting") is the tell
  that it should be enforced, not just documented.
