# ai-research — AI coding agent toolkit

Reusable **workflows**, **guides**, and drop-in **`.claude/` templates** for
doing real engineering with AI coding agents, with the primary sources
vendored alongside so nothing rots behind a dead link.

Everything here started as something built for a real project, then got
generalized. Maturity is tracked honestly in [catalog/](catalog/) — some
patterns are `Running` in production use, some are `Template, untested`, and
that distinction is never hidden.

> This is the shared toolkit subset of a larger personal research lab. The
> private half — working-state snapshots, session journals, and one specific
> project's improvement backlog — is intentionally not included; it's
> situational to one person and useless to you. What's here is the part
> designed to be reused.

---

## Use this in your own project

**Fastest path:** open a Claude Code session in your target project and run
`/onboard-project` (defined in `.claude/commands/onboard-project.md`). It
interviews you briefly, picks an install tier (MINIMAL / STANDARD / FULL, plus
a BUSINESS bundle for venture/product-strategy work), and copies the relevant
templates from `tooling/` into your project's `.claude/` — filling in the
bracketed `<…>` placeholders as it goes.

**Manually instead:** every template in `tooling/` is self-contained. Copy the
file, replace the `<…>` placeholders (test command, standards-file paths, doc
locations), and drop it into `<your-project>/.claude/skills/`, `.claude/commands/`,
or `.claude/agents/`. Start at [tooling/README.md](tooling/README.md) for the
full catalog. If you're not sure which *pattern* fits your problem, start at
[catalog/](catalog/) — the decision menu that `tooling/` implements.

**Prerequisites:** [Claude Code](https://code.claude.com), or any harness that
reads the same `.claude/` conventions (skills, commands, subagents, hooks).
Nothing here is tied to a language, framework, or cloud service.

---

## What's in here

| Folder | What's in it | Start here when… |
|---|---|---|
| [`tooling/`](tooling/) | Portable skill/command/agent **templates** ready to drop into any `.claude/` | you want to install a capability into a real repo |
| [`catalog/`](catalog/) | Decision catalog of agent & skill **patterns** — pros/cons, efficiency, Maturity/Evidence flags | you're choosing *which* pattern fits a requirement |
| [`guides/`](guides/) | Mechanism references: the tool surface, skills vs commands vs agents vs hooks, writing skills, context/subagents | you're configuring tooling or unsure which mechanism to use |
| [`workflows/`](workflows/) | End-to-end processes: idea→ship, debugging loop, codebase health, onboarding, venture pipeline | you're starting a piece of work and want the route |
| [`research/`](research/) | Dated notes distilling the *why* — AI coding workflow, context engineering, harness & loop engineering | you want the reasoning, not just the practice |
| [`references/`](references/) | Primary sources **vendored** (not linked), each with a written summary | you want to check the original |
| [`CONCEPTS.md`](CONCEPTS.md) | One line per principle/pattern with a source link | you want the whole map in one read |

---

## The 60-second orientation

1. **The one principle under everything is `task → do → verify`.** AI's value
   isn't one-shotting to 100% — it's the *speed of iterating* to ~100% through
   a verification loop. Every task needs a way for the agent to judge its own
   output (tests, screenshots, type-checks, acceptance criteria). No loop =
   most of the value thrown away.

2. **The canonical workflow is `idea → align → spec → slice → implement →
   review → handoff`.** Align by *grilling* (one question at a time). Slice
   *vertically*, never by layer. Review in *fresh context*. Throw planning docs
   away once the code lands. See [workflows/idea-to-ship.md](workflows/idea-to-ship.md).

3. **Context is the bottleneck.** The early window is the highest-quality real
   estate; treat it as scarce. Keep instruction files tight, isolate volume and
   bias into subagents, prefer skills over MCP. See
   [guides/context-and-subagents.md](guides/context-and-subagents.md).

4. **Harness engineering: every mistake becomes a permanent fix.** When an
   agent gets something wrong, the response isn't a one-off correction — it's a
   doc line, a hook, or a verification tool that makes the mistake structurally
   harder to repeat. See
   [research/2026-07-19_harness-and-loop-engineering.md](research/2026-07-19_harness-and-loop-engineering.md).

5. **Six vendored sources anchor all of this** — Matt Pocock's `skills` (the
   workflow *verbs*), shanraisshan's `claude-code-best-practice` (the tooling
   *nouns*), three Anthropic official sources (Agent Skills spec+template,
   Claude Code plugins, "Building Effective Agents" notebooks), and `ponytail`
   (the anti-over-engineering ruleset). Summarized in
   [references/README.md](references/README.md).

---

## Conventions worth stealing

- **Vendor, don't link.** External references live under `references/<name>/`
  with a `VENDORED.txt` (source URL, clone date, commit, upstream license) —
  a link rots, a vendored copy doesn't.
- **Templates carry no hardcoded paths** — only bracketed `<…>` placeholders,
  so they're copy-able into any repo.
- **Maturity is tracked, not assumed.** Every pattern is tagged `Conceptual` /
  `Template, untested` / `Running`, so you know what's a real recommendation.
- **Claims carry sources.** Load-bearing claims are tagged `[verified — source]`,
  `[self-reported]`, or `[hypothesis]` — external benchmarks and vendor numbers
  are never presented as fact.

---

## License

This repository's own content (research notes, guides, workflows, catalog, and
the `tooling/` templates) is MIT-licensed — see [LICENSE](LICENSE).

Vendored material under `references/` keeps its original upstream terms —
check each subfolder's `VENDORED.txt` before reusing it; not everything there
carries a confirmed open-source license.
