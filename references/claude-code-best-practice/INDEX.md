# claude-code-best-practice — vendored index

Curated copy (see `VENDORED.txt`). Replaces the upstream's 76KB badge-heavy
README with this clean map. shanraisshan's repo is the **encyclopedia of Claude
Code mechanics** — a worked example of every feature, with a "best-practice"
writeup and an "implemented" sample for each. Use it to look up *how a mechanism
works*; use Pocock's repo and `../../workflows/` for *how to run a project*.

## Where to look

| Topic | Best-practice writeup | Worked sample |
|---|---|---|
| **Subagents** | [best-practice/claude-subagents.md](best-practice/claude-subagents.md) | [implementation/claude-subagents-implementation.md](implementation/claude-subagents-implementation.md), `.claude/agents/*.md` |
| **Commands** | [best-practice/claude-commands.md](best-practice/claude-commands.md) | [implementation/claude-commands-implementation.md](implementation/claude-commands-implementation.md), `.claude/commands/*.md` |
| **Skills** | [best-practice/claude-skills.md](best-practice/claude-skills.md) | [implementation/claude-skills-implementation.md](implementation/claude-skills-implementation.md), `.claude/skills/*/SKILL.md` |
| **Hooks** (all 30 events) | [.claude/hooks/HOOKS-README.md](dot-claude/hooks/HOOKS-README.md) | [.claude/hooks/scripts/hooks.py](dot-claude/hooks/scripts/hooks.py), [.claude/hooks/config/hooks-config.json](dot-claude/hooks/config/hooks-config.json) |
| **MCP** | [best-practice/claude-mcp.md](best-practice/claude-mcp.md) | [.mcp.json](dot-mcp.json) |
| **Settings / permissions / model config** | [best-practice/claude-settings.md](best-practice/claude-settings.md) | [.claude/settings.json](dot-claude/settings.json) |
| **Memory & rules** | [best-practice/claude-memory.md](best-practice/claude-memory.md) | `.claude/rules/*.md`, [.claude/agent-memory/](dot-claude/agent-memory/) |
| **CLI startup flags** | [best-practice/claude-cli-startup-flags.md](best-practice/claude-cli-startup-flags.md) | — |
| **Power-ups** | [best-practice/claude-power-ups.md](best-practice/claude-power-ups.md) | — |
| **Orchestration** (one command → subagents) | [orchestration-workflow/orchestration-workflow.md](orchestration-workflow/orchestration-workflow.md) | [.claude/commands/weather-orchestrator.md](dot-claude/commands/weather-orchestrator.md) |
| **Agent teams** (parallel swarms) | [agent-teams/agent-teams-prompt.md](agent-teams/agent-teams-prompt.md) | [agent-teams/dot-claude/](agent-teams/dot-claude/) |
| **RPI dev workflow** (research→plan→implement, multi-agent) | [development-workflows/rpi/rpi-workflow.md](development-workflows/rpi/rpi-workflow.md) | [development-workflows/rpi/dot-claude/](development-workflows/rpi/dot-claude/) |
| **Cross-model workflow** | [development-workflows/cross-model-workflow/cross-model-workflow.md](development-workflows/cross-model-workflow/cross-model-workflow.md) | — |

## Deep-dive reports (`reports/`)

Standalone investigations worth knowing exist:
`claude-agent-memory` · `claude-global-vs-project-settings` ·
`claude-advanced-tool-use` · `claude-agent-command-skill` (when to use which) ·
`claude-skills-for-larger-mono-repos` · `claude-agent-sdk-vs-cli-system-prompts` ·
`claude-usage-and-rate-limits` · `claude-in-chrome-v-chrome-devtools-mcp` ·
`llm-day-to-day-degradation` · `why-harness-is-important` ·
`claude-spinner-verbs-and-tips` · `learning-journey-weather-reporter-redesign`.

## How this maps to the rest of ai-research

The mechanics here are **distilled into [../../guides/](../../guides/)** so you
don't re-read the encyclopedia each time — open these files for the full worked
sample a guide points at. Pocock = the verbs (what to do); this = the nouns (the
mechanisms).
