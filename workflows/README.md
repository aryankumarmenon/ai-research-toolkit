# workflows/

End-to-end processes — the *route* to take for a given kind of work. Where
[`guides/`](../guides/) explains mechanisms in isolation, workflows chain them
into a sequence you actually run.

| Workflow | Use when | File |
|---|---|---|
| **Idea → Ship** | Building any non-trivial feature | [idea-to-ship.md](idea-to-ship.md) |
| **Debugging loop** | Something is broken, throwing, failing, or slow | [debugging-loop.md](debugging-loop.md) |
| **Codebase health** | Upkeep — keeping the code good for agents to operate in | [codebase-health.md](codebase-health.md) |
| **NAO pipeline mapping** | Working in `sf-nao-admin` with the Claude+Devin split | [nao-pipeline-mapping.md](nao-pipeline-mapping.md) |
| **NAO admin dev loop** | The `sf-nao-admin` environment, local dev/deploy/verify loop, and org-safety guardrails | [nao-admin-dev-loop.md](nao-admin-dev-loop.md) |
| **Onboard a new project** | Set up AI tooling for any new repo — interview, size the install (minimal/standard/full), drop in templates from `tooling/` | [onboard-project.md](onboard-project.md) |
| **Venture pipeline** | Taking a product/business idea from hunch to a validated, gated plan — grill → research → verify → position → plan → dev handoff | [venture-pipeline.md](venture-pipeline.md) |

**The router habit:** if you're not sure which workflow or skill fits, ask the
agent — that's exactly what Pocock's `ask-matt` router is for. Don't try to hold
the whole map in your head.

**The invariant across all of them:** every workflow ends on a *verification
loop* and discards its planning artifacts once code lands. A workflow with no
loop throws away most of the value; a workflow that hoards stale planning docs
misleads the next session.
