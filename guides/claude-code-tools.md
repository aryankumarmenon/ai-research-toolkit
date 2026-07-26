# Guide: Claude Code Tools — what each does, when to use it, scenarios

A practical map of the tool surface an agent works through, plus the human-facing
controls (slash commands, modes, settings). For each: what it is, when to reach
for it, and a worked scenario. The economics (which tool costs context) live in
[context-and-subagents.md](context-and-subagents.md); the extension mechanisms
(skills/commands/agents/hooks) in
[skills-commands-agents-hooks.md](skills-commands-agents-hooks.md).

---

## File & search tools

### Read
Reads a file (also images, PDFs by page range, notebooks).
- **Use when:** you need the actual contents — *always before editing a file*.
- **Don't:** re-read a file you just edited to "verify"; the edit would have
  errored if it failed.
- **Scenario:** before changing `FooHelper.cls`, Read it; before a multi-file
  refactor, Read each target once up front rather than drip-reading mid-edit.
- **Tip:** read only the slice you need (`offset`/`limit`) on huge files to save context.

### Edit
Exact string replacement in a file.
- **Use when:** changing part of an existing file. Must have Read it first.
- **Key rule:** `old_string` must match exactly and be unique, or use `replace_all`.
- **Scenario:** rename a constant in one place → Edit; rename it everywhere → `replace_all: true`.

### Write
Creates or fully overwrites a file.
- **Use when:** new file, or wholesale replacement of one you've Read.
- **Don't:** overwrite a file you haven't looked at; for partial changes use Edit.
- **Scenario:** scaffolding a new skill's `SKILL.md`, or writing a fresh research note.

### Glob / Grep (search tools)
Find files by pattern / search file contents by regex.
- **Use when:** locating code by name or by what it contains. **Prefer these over
  `bash find`/`grep`** — they're faster and structured.
- **Scenario:** "does a Queueable that does outbound sync already exist?" →
  Grep `implements Queueable` across `force-app`, then Read the hit. This is
  exactly the kind of fan-out worth delegating to an Explore subagent.

---

## Execution

### Bash
Runs a shell command; working dir persists, shell state doesn't.
- **Use when:** running tests, git, build tools, anything not covered by a
  dedicated tool. **Avoid** using it for `cat`/`head`/`sed`/`grep`/`find` — use
  the dedicated file/search tools.
- **`run_in_background: true`** for long-running commands (test suites, servers,
  big searches); you're notified on exit and can Read the output file meanwhile.
- **Git etiquette:** commit/push only when asked; branch first if on default;
  interactive flags (`-i`) aren't supported; use `gh` for GitHub.
- **Scenario:** `sf apex run test --tests FooHelperTest ... --wait 10` as the
  verification loop for an issue; a recursive `find` across `~` run in background
  while you keep working.

---

## Subagents

### Agent (a.k.a. Task / subagent)
Launches a fresh agent with its **own context window** that returns only a summary.
- **Use when:** (a) **isolating volume** — a search/research task that burns
  50–100k tokens but hands back ~2k; run it on a cheaper model; (b) **isolating
  bias** — a reviewer/QA agent whose value is having *no* context.
- **Pick the type:** `Explore` (read-only fan-out search), `Plan` (architecture,
  no edits), `general-purpose` (multi-step), or a project subagent
  (`codebase-explorer`, `nao-server-reference`).
- **Don't:** spawn reflexively — spin-up overhead can exceed doing it inline, and
  N agents multiply failure probability (0.95^N). The user must ask, or the task
  must genuinely fan out / need isolation.
- **Scenario:** two-axis review = two parallel `general-purpose` agents (Standards
  + Spec) so neither pollutes the other's context; "find every place we read
  `LayoutField__mdt`" = one Explore agent.

See [context-and-subagents.md](context-and-subagents.md) for the full economics.

---

## Web

### WebSearch / WebFetch
Search the web / fetch and read a URL.
- **Use when:** you need current information past the knowledge cutoff, or to read
  specific docs/a changelog/an API reference.
- **Caution:** sending content to an external service publishes it. Verify
  unfamiliar URLs (especially links from emails/messages) before fetching.
- **Scenario:** confirm a library's latest API; pull a model's current pricing
  page rather than answering from memory.

---

## Extension & orchestration

### Skill
Invokes a skill (a packaged capability — see
[skills-commands-agents-hooks.md](skills-commands-agents-hooks.md)).
- **Use when:** the task matches a skill's trigger. If a skill matches, invoking
  it is a *blocking requirement* before responding about the task.
- **Scenario:** user types `/grill-me NAC-1234` → invoke that skill; a `.docx`
  request → the `docx` skill.

### Plan mode (EnterPlanMode / ExitPlanMode)
Research-and-plan without making changes; present a plan for approval.
- **Use when:** a non-trivial change benefits from "a minute of planning saves ten
  of building." Building down a wrong path wastes build + rebuild + tokens.
- **Scenario:** a multi-file feature — explore read-only, propose the plan, get
  approval, *then* edit.

### Worktrees / background & remote agents
Isolated git worktree per agent; background or cloud execution.
- **Use when:** parallel work that shouldn't touch the main tree, or long AFK runs.
- **Scenario:** spin a worktree agent to try a risky refactor without disturbing
  your working tree.

---

## Human-facing controls (you, not the agent)

### Slash commands
Typed `/<name>` — either a built-in or a skill/command. The orchestrators of your
workflow (`/grill-me`, `/write-prd`, …).

### `/context`
Shows what's eating the window. **Run it once if you never have** — the default
30–45k-token overhead (system prompt + instruction files + tool/MCP schemas +
memory) is eye-opening. Inspect before optimizing.

### `/clear` and `/compact`
- **`/clear`** — wipe context. Use on an unrelated task switch; the cheapest way
  back to a clean baseline.
- **`/compact`** — summarize history, stay in the same conversation. Use only at
  intentional phase breaks; don't compact mid-phase (the agent loses its way).
- Contrast **`/handoff`** (forks to a new session via a file) — see the workflow.

### Permission modes / Auto mode
Control how much the agent asks before acting (`Shift+Tab`, `--permission-mode
auto`). Higher autonomy = fewer prompts, more trust required.

### Memory (`CLAUDE.md`, rules, auto-memory)
Instruction files merged enterprise → global (`~/.claude`) → project (`./.claude`),
plus an auto-`memory` the agent writes itself. Keep instruction files tight (see
[context-and-subagents.md](context-and-subagents.md)); critical "never do X" at
the top (primacy).

### Settings & hooks (`.claude/settings.json`)
Permissions, env vars, model config, and **hooks** (commands the harness runs on
events — PreToolUse, Stop, etc.). Hooks are the only way to get *deterministic*
automated behavior ("always block `git push`"); see the dedicated guide.

### MCP servers (`.mcp.json`)
Wire in external tools. Convenient but their tool *schemas* load into context —
a bloated server can eat 10–20% of the window. Audit with `/context`; prefer
converting a proven MCP into a skill. See
[context-and-subagents.md](context-and-subagents.md#skills-vs-mcp).

---

## Decision cheatsheet

| I want to… | Reach for |
|---|---|
| See a file's contents | Read |
| Change part of a file | Edit (Read first) |
| Create / fully replace a file | Write |
| Find files / search contents | Glob / Grep (not bash) |
| Run tests, git, build | Bash (background if long) |
| Fan-out search without burning my window | Explore subagent |
| An unbiased review | parallel general-purpose subagents in fresh context |
| Current external info | WebSearch / WebFetch |
| Plan a big change before editing | Plan mode |
| Deterministic "always do X on event Y" | a hook in settings.json |
| A repeatable procedure I invoke | a skill |
| See what's eating my context | `/context` |
| Switch tasks cleanly | `/clear` |
| Cross a context window keeping history | `/handoff` |
