# claude-code-plugins — vendored index

Curated copy (see `VENDORED.txt`) of Anthropic's **official Claude Code plugins**
and hook/settings examples from [`anthropics/claude-code`](https://github.com/anthropics/claude-code).

Where Pocock's repo is *workflow discipline* and shanraisshan's is the *mechanics
encyclopedia*, this is the **reference implementation** — Anthropic's own version
of the same patterns this workspace builds by hand. Read a plugin when you want to
see how the vendor structured a command/agent/hook bundle, or to lift a piece into
`../../tooling/`.

> Each plugin's manifest dir was renamed `.claude-plugin/` → `dot-claude-plugin/`
> so nothing auto-registers here. To actually *use* these, install from upstream
> in a real project: `/plugin marketplace add anthropics/claude-code`.

## Plugins kept (and why this workspace cares)

| Plugin | Ships | Relevance here |
|---|---|---|
| [`hookify/`](plugins/hookify/) | 4 commands · 1 agent · 1 skill · 6 hook files | Create guardrail hooks from a natural-language rule + regex, no `hooks.json` editing. The **official, ergonomic version** of the usage-logging/nudge hooks built in `sf-nao-admin` — see [`../../catalog/agents.md`](../../catalog/agents.md) self-improvement entry and [`../../tooling/usage-logging-hooks/`](../../tooling/usage-logging-hooks/). |
| [`ralph-wiggum/`](plugins/ralph-wiggum/) | 3 commands · 2 hook files | The "Ralph is a Bash loop" technique — a **Stop hook** that blocks exit and re-feeds the same prompt until a completion promise. The concrete Claude-Code realization of the **self-improvement / auto-research loop** in [`../../research/2026-06-28_auto-research-and-harnesses.md`](../../research/2026-06-28_auto-research-and-harnesses.md). |
| [`feature-dev/`](plugins/feature-dev/) | 1 command · 3 agents (explore, architect, review) | Anthropic's ticket→ship feature workflow. Direct analogue of the NAO pipeline (`grill → prd → issues → implement → review`); compare its agent split to `../../workflows/idea-to-ship.md`. |
| [`code-review/`](plugins/code-review/) | 1 command · confidence-scored agents | Automated PR review with confidence scoring — compare to the two-axis review in [`../../tooling/skill-templates/two-axis-review.md`](../../tooling/skill-templates/two-axis-review.md). |
| [`pr-review-toolkit/`](plugins/pr-review-toolkit/) | 1 command · 6 specialist agents | Review split into specialists (comments, tests, error-handling, type-design, quality, simplification) — a worked **fan-out** roster for `../../catalog/agents.md`. |
| [`commit-commands/`](plugins/commit-commands/) | 3 commands | Simple commit/push/PR commands. Reference only — `sf-nao-admin` deliberately does **no** git (Devin owns it). |
| [`plugin-dev/`](plugins/plugin-dev/) | 1 command · 3 agents · **7 authoring skills** | How to author plugins/commands/agents/hooks/skills/MCP the official way. Backs [`../../guides/writing-skills.md`](../../guides/writing-skills.md) and the skills-vs-commands-vs-agents-vs-hooks guide. |
| [`security-guidance/`](plugins/security-guidance/) | 12 hook files | Pattern warnings on edit + LLM diff-review on Stop + agentic commit reviewer (injection/XSS/SSRF/secrets/25+ classes). A worked example of hooks doing real review work. |

## Examples (`examples/`)

| Path | What |
|---|---|
| [`examples/hooks/bash_command_validator_example.py`](examples/hooks/bash_command_validator_example.py) | Canonical PreToolUse validator hook (blocks/normalizes bash) — the primitive under `hookify` and the `sf-nao-admin` hooks. |
| [`examples/settings/`](examples/settings/) | Official `settings-strict.json` / `settings-lax.json` / `settings-bash-sandbox.json` + README — the authoritative shape for a `settings.json`, incl. `permissions` and `hooks` blocks. |

Repo README and full release history kept as
[`UPSTREAM-README.md`](UPSTREAM-README.md) and [`CHANGELOG.md`](CHANGELOG.md).
