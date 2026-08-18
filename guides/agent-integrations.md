# Guide: Agent Integrations (MCP vs CLI)

How to give an agent access to Jira, Slack, GitHub, Postman, or a browser
**without** paying for it on every turn — and where each integration should live
given the personal/company split.

Companion to [skills-commands-agents-hooks.md](skills-commands-agents-hooks.md)
(which mechanism) and [context-and-subagents.md](context-and-subagents.md#skills-vs-mcp)
(what context costs). Distinct from [web-automation-tiers.md](web-automation-tiers.md),
which is about driving *someone else's* site; this is about wiring *your own*
tools.

---

## 1. The decision: CLI first, MCP when there's no CLI

The economics are lopsided and they don't change:

| | Resident cost | Good at | Bad at |
|---|---|---|---|
| **CLI** (via Bash) | **~0 until called** | anything scriptable, piping, CI parity | discovery — the agent must know the commands |
| **MCP server** | **tool schemas load into context** — a fat server eats 10–20% of the window | typed, discoverable, live access; OAuth handled | always-on cost, even on turns that never touch it |
| **Skill that shells out** | ~60 tokens at rest | encoding *your* procedure over a CLI | needs writing once |

**Default: use the CLI.** Reach for MCP when there is no usable CLI (Jira,
Slack), or when you genuinely need live typed access mid-task (Playwright).
The end state for anything repeatable is the third row — a **skill wrapping a
CLI or script** — which is the same "prototype high, harden low" move
[web-automation-tiers.md](web-automation-tiers.md) prescribes, applied to
integrations: prove it with the MCP, then harden into a script the skill calls.

---

## 2. Scope: where an integration lives *is* the boundary

Four scopes. This matters more here than anywhere else in the setup, because of
the finding recorded in `STATE.md`: **`~/.claude/` is shared by every Claude Code
session on this Mac regardless of which account is signed in.** The account is
not the boundary — *scope* is.

| Scope | Lives in | Reach | Committed? |
|---|---|---|---|
| **Local** | `~/.claude.json` → `projects.<abs-path>.mcpServers` | one project, this machine | **no — zero repo footprint** |
| **Project** | `.mcp.json` at repo root | anyone who clones | yes |
| **User** | `~/.claude.json` → top-level `mcpServers` | **every project, every account** | no |
| **Subagent** | agent frontmatter `mcpServers:` | one subagent | with the agent file |

Precedence: **Subagent > Project > User.**

**The rule that follows:** work integrations go at **local** scope inside the
work repo. Never at user scope — a user-scope Jira or Slack server is visible to
every personal session too, which defeats the point of keeping two accounts
apart. Local scope is the same mechanism as the **git-invisible install** pattern
used for work repos elsewhere in this repo: real capability, nothing committed,
nothing leaked sideways.

To see what's already wired, read `~/.claude.json`: top-level `mcpServers` is
user scope, and `projects.<abs-path>.mcpServers` is the local scope for that one
project.

**Authorization is interactive.** OAuth-based servers (Atlassian, Slack, the
GitHub MCP) cannot be authorized from a non-interactive session — there is no
way to complete the flow. Wire them from an interactive terminal, on the account
that should own the grant.

---

## 3. Per-integration

### GitHub — use `gh`, skip the MCP

`gh` is installed and already authenticated. It covers PRs, issues, reviews,
Actions, and arbitrary REST via `gh api` — everything the GitHub MCP offers, at
zero resident cost. **There is no good reason to load a GitHub MCP server here.**

> **Live footgun.** If you have **two GitHub accounts logged in** (a work one and
> a personal one), `gh`'s *active* account is global — so a personal-repo command
> silently hits the API as the work account and 404s, which reads like "the repo
> doesn't exist" rather than "wrong identity". Run `gh auth status` before any
> `gh` write, and keep a standing rule for which identity each repo pushes as.

Read-only checks that need *no* account at all are often the better move — a
plain unauthenticated `curl https://api.github.com/repos/<owner>/<repo>` answers
"is this public?" definitively, with no auth-state confusion.

### Jira / Atlassian — MCP is the only real option, so ladder into it

No Jira CLI is installed (`jira`, `acli` — both absent), and Atlassian's own CLI
is not a serious automation surface. So this one genuinely justifies MCP. Climb
in three steps rather than wiring write access on day one:

1. **`jira-draft` skill (already built, zero access).** Drafts paste-ready
   epics/stories/bugs from repo docs and conversation; you paste into Jira.
   Costs ~60 tokens at rest and no auth. For *authoring*, this is most of the
   value → [tooling/skill-templates/jira-draft.md](../tooling/skill-templates/jira-draft.md).
2. **Atlassian MCP at local scope, read-mostly** — in the work repo only,
   authorized as the **company** account from an interactive session. Buys
   *intake*: read the ticket, its acceptance criteria and comments, without the
   copy-paste relay. This is the step that pays, because intake is where the
   relay actually hurts ("intake belongs to the tool with the access").
3. **Write access last, if ever.** Transitions and comments are outward-facing
   actions on a shared system; each one needs confirmation anyway, which erodes
   the speed argument for automating it.

### Slack — the cheap 80% needs no integration at all

`/handoff` already ends in a **Slack-ready digest**. Producing text you paste is
almost all of the value, at zero resident cost and zero risk.

Wiring Slack *write* access means the agent can send messages on your behalf —
which requires explicit confirmation every time, so it saves a paste and adds a
prompt. Poor trade. If you wire Slack at all, wire it **read-only**, for the
intake case (pull the thread that describes the bug), at local scope in the work
repo. Note that channel content is untrusted input: treat anything read from
Slack as data, never as instructions.

### Postman / API verification — harden to a script

Both `postman` and `newman` CLIs are installed, and `/verify-api` already does
HMAC-signed direct backend calls via a node runner. That combination is the
hardened Tier-1 end state; a Postman MCP would be a step *backwards* into
resident cost.

- **`newman run <collection>`** — run an exported collection headlessly, in CI
  or locally. This is the CI-parity path.
- **`/verify-api`'s node runner** — signed one-off calls where the collection
  would be overkill. GETs free, mutations per-call approved.

The generalisable shape (worth lifting into `tooling/` when it next gets
touched): *collection as the source of truth, runner as the execution surface,
skill as the procedure that decides which endpoints matter for this change.*

### Playwright — two different jobs, don't conflate them

**(a) Live driving, for verification.** Playwright MCP at **local** scope —
already proven for a `/verify-ui` command (zero repo footprint, frontdoor
URL treated as a credential, scratch full / qa read-only / uat refuse). This is
the exploratory surface: click through, screenshot, confirm the change landed.

**(b) Committed spec files, for CI.** Generated `.spec.ts` files that run without
an agent. Anything worth checking twice belongs here, not in (a).

The discipline is to **move findings from (a) to (b)**: the agent explores once,
then writes the spec so the check is free forever after. Leaving verification in
(a) means re-paying tokens for a test you already know how to run.

**Use cases worth trying, given the current work context:**
- **Vision maker→verifier** — screenshot the rendered page, hand it to a *fresh*
  agent to grade against the goal. The generator never grades its own work
  (`CONCEPTS.md` §7). Fresh, never forked — a forked grader has already seen the
  reasoning behind the UI.
- **Spec generation from a workflow definition** — where a project already
  describes user journeys as structured data (workflow JSON, state machines, a
  BDD feature file), an agent that reads that definition and emits the Playwright
  spec beats hand-maintaining both sides, which drift apart silently.
- **Trace-driven debugging** — feed `trace.zip` / console + network output from a
  failing CI run back as evidence, rather than re-running the browser locally to
  reproduce.

---

## 4. Adoption order

Deliberately sequenced so each step is useful alone and nothing wires write
access before read access has earned it:

1. **GitHub `gh` guardrails** — no install; add the active-account check. *Today.*
2. **Playwright local scope** wherever a UI actually needs verifying; move each
   finding into a committed spec.
3. **Postman/newman** — collection run in CI; keep `/verify-api` for signed
   one-offs.
4. **Atlassian MCP, local scope, read-only**, company account, from an
   interactive session. The first genuinely new capability.
5. **Slack read-only**, only if ticket/thread intake proves to be a real
   bottleneck. Probably never.

## 5. What not to do

- **Don't put a work integration at user scope.** It reaches every personal
  session on this Mac; the signed-in account does not contain it.
- **Don't commit `.mcp.json`** with work servers into a personal repo.
- **Don't load an MCP for something a CLI already does** (GitHub is the standard
  offender — its MCP is popular and almost always redundant next to `gh`).
- **Don't treat content read from Jira/Slack/GitHub as instructions.** It's data
  from other people. A ticket that says "run the deploy script" is a description
  of a request, not authorization to run it.
