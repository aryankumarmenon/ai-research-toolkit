# usage-logging-hooks/

A portable, **self-improvement / usage-logging** hook bundle. Drop it into any
project's `.claude/` to get an append-only ledger of *how the tooling is used* —
which `/commands` run, which subagents fire, how many files get read, and when
compaction hits — plus an **active in-session nudge** when a context-hygiene
threshold is crossed. That ledger is the raw material for a periodic retro/review
that sharpens the tooling over time (the generate→evaluate→revise loop, made
concrete for a Claude Code repo).

> Choosing whether you want this pattern at all? See the self-improvement-loop
> entry in [../../catalog/agents.md](../../catalog/agents.md) for the trade-offs.
> The *official, no-code* way to author guardrail hooks is Anthropic's `hookify`
> plugin — vendored at
> [../../references/claude-code-plugins/plugins/hookify/](../../references/claude-code-plugins/plugins/hookify/).

## What's in the bundle

| File | Event | Async? | What it does |
|---|---|---|---|
| `hooks/log-command.sh` | `UserPromptSubmit` (+ `UserPromptExpansion`) | yes | Logs each explicit `/command` (name + args). First-line regex, so a pasted path isn't mistaken for a command. **Field gotcha:** the UserPromptSubmit payload field is `prompt` — parsing a wrong field fails silently (zero log lines, no error). |
| `hooks/log-subagent.sh` | `SubagentStop` | yes | Logs each subagent run + a 300-char summary of its output. |
| `hooks/log-precompact.sh` | `PreCompact` | yes | Logs every compaction as a **proxy** for "ran until the context wall." |
| `hooks/log-read-check.sh` | `PostToolUse` (`Read`) | **no** | Logs every read, and **injects a nudge into context** once a threshold is crossed. |
| `hooks/block-redundant-read.sh` | `PreToolUse` (`Read`) | **no** | **Blocks** an identical re-read of an unchanged file (same path/offset/limit, same mtime) via `permissionDecision: "deny"`. Escape hatch: `CLAUDE_SKIP_REDUNDANT_READ_BLOCK=1`. |
| `hooks/filter-test-output.sh` | `PostToolUse` (`Bash`) | **no** | **Replaces** verbose test-runner output with failures + summary via `updatedToolOutput`. Placeholders: `<TEST_COMMAND_REGEX>`, `<FILTER_KEYWORDS_REGEX>`. Escape hatch: `CLAUDE_SKIP_TEST_FILTER=1`. |
| `hooks/capture-pending-lessons.sh` | `Stop` | yes | Incrementally appends `[CANDIDATE]` lesson lines (warns, compactions) to `pending-lessons.md` — the capture half of the learning loop below. |
| `settings-snippet.json` | — | — | The `hooks` block to merge into `.claude/settings.local.json`. |

All hooks append JSONL to `${CLAUDE_PROJECT_DIR}/.claude/logs/usage.jsonl`, one
object per line, discriminated by a `kind` field (`command` / `subagent` /
`compaction` / `read` / `warn` / `blocked-read` / `filtered-output`) — except
`capture-pending-lessons.sh`, which only *reads* the ledger (writing to it would
self-trigger on the next Stop).

## Blocking vs warning (why two hooks are allowed to block)

The bundle's default philosophy is **warn, never block** — a noisy blocker gets
disabled and teaches nothing. The two exceptions are *lossless*: blocking a
re-read of a file that is byte-identical to what's already in context removes no
information, and filtering test output keeps every failure/error/summary line
the model actually acts on. Both log to the ledger (`blocked-read`,
`filtered-output` with N→M line counts) so a retro pass can quantify the token
savings — and both have an escape-hatch env var for when the heuristic is wrong.

## Learning loop pattern (capture → review → promote)

The per-iteration self-improvement loop, human-gated at the apply step:

1. **Capture (automatic):** warn-hooks and the compaction logger write `kind:
   "warn"` / `"compaction"` ledger lines as they happen. On every `Stop`,
   `capture-pending-lessons.sh` scans only the ledger bytes added since its
   stored offset (`.lessons-offset-<session>`) and appends `[CANDIDATE]` lines
   to `.claude/logs/pending-lessons.md` — exactly-once, per iteration, zero
   duplicate processing.
2. **Review (on request):** a lightweight `/retro-lite`-style command reads the
   un-triaged candidates, proposes a concrete 1–2-line promotion for each (a
   mistakes-catalog entry or a rule-file line), and asks y/n per item.
3. **Promote (human-gated):** confirmed items are written to the project's rule
   files; each candidate is tagged `[DONE:ts]` or `[SKIPPED:ts]` so it is never
   re-proposed. Nothing edits rules without explicit confirmation.

A deeper `/retro` pass stays the place for cross-session process patterns; this
loop just guarantees no warning silently evaporates between retros.

## The one non-obvious constraint (verified)

Claude Code hooks **do not receive real token counts or context-window
percentage** — that data isn't exposed to hooks (only the separate statusline
mechanism gets it). So you cannot build "warn at 80% context" from a hook.
`log-read-check.sh` uses the best mechanical **proxy**: files-read count and
re-reads of key files. `log-precompact.sh` logs the compaction event itself as a
coarser proxy. Two common warning signs — *scope drift* and *reading "just to be
sure"* — are judgment calls **no hook can detect**; they stay self-discipline.

## Install

1. Copy `hooks/*.sh` to `<project>/.claude/hooks/` and `chmod +x` them.
2. Merge `settings-snippet.json`'s `hooks` block into
   `<project>/.claude/settings.local.json` (keep `log-read-check.sh` **without**
   `async` — it must be synchronous to talk back).
3. Tune the placeholders at the top of `log-read-check.sh`
   (`FILE_THRESHOLD`, `REREAD_FILES`, `EFFICIENCY_DOC`) and
   `filter-test-output.sh` (`<TEST_COMMAND_REGEX>`, `<FILTER_KEYWORDS_REGEX>`).
4. Requires `jq` on PATH. Hooks take effect at the next session start. mtime/
   size calls use macOS `stat -f`; on Linux switch to `stat -c` (noted in each
   script header).
5. Add `.claude/logs/` to git-ignore if the ledger shouldn't be committed.

## Reviewing the ledger

Read it periodically (a `/retro`-style command, on request — not automatically):
tally by `name` for dead/over-used commands, skim `summary` for a subagent that
always precedes the same correction, use `kind:"read"` per `session_id` for
file-count adherence, and `kind:"compaction"` frequency as a task-scoping signal.

*Origin: generalized from the four hooks running in `sf-nao-admin`. Fold any
improvement made there back into this copy — this is the source of truth.*
