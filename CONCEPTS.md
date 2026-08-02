# CONCEPTS.md — the one-shot concept map

One line per distinct concept/pattern/principle in this repo, linked to its source.
Read this to understand everything before diving anywhere.
NOT a file index (that's README.md). NOT a current-state snapshot (that's STATE.md).
This is the durable concept layer — maintained by /sync-context Step 6 (net-new concepts only; prune superseded).

---

## 1. Core principles

- **task → do → verify** — AI's value is loop speed to ~100%, not one-shotting → `research/2026-06-27_ai-coding-workflow.md`
- **Canonical build flow** — idea → align(grill) → spec → slice → implement(test-first) → review(fresh context) → handoff → `workflows/idea-to-ship.md`
- **Vertical slices (tracer bullets), never horizontal layers** — → `workflows/idea-to-ship.md`
- **Front-load research** — a minute of planning saves ten of building → `research/2026-06-27_ai-coding-workflow.md`
- **Intake belongs to the tool with the access** — never relay via human → `research/2026-06-27_ai-coding-workflow.md`
- **"Prefactoring"** — make the change easy first, then make the easy change → `workflows/idea-to-ship.md`
- **Laziness ladder (ponytail)** — before writing code, stop at the first rung: YAGNI → reuse → stdlib → platform → dependency → one line → minimal code; write-time counterpart to the review-time deletion test; never lazy about trust boundaries/data loss/security/a11y → `tooling/claude-md-blocks/laziness-ladder.md` · `references/ponytail/`

---

## 2. Context & tokens

- **30–45k token fixed overhead** — system prompt, tools, MCP, memory consumed before the first prompt → `research/2026-06-27_context-engineering-and-agent-config.md`
- **Smart zone** — quality degrades past ~100–120k tokens ("context rot") → `research/2026-06-27_context-engineering-and-agent-config.md`
- **Primacy/recency** — hard rules at the TOP of instruction files; bury nothing critical in the middle → `research/2026-06-27_context-engineering-and-agent-config.md`
- **Instruction file discipline** — 200–500 lines max, pointer-style, prune like tech debt; add a rule when the same mistake recurs 2–3× (Claude Code `/doctor` ≥v2.1.206 now proposes CLAUDE.md trims automatically) → `research/2026-06-27_context-engineering-and-agent-config.md`
- **Few-shot examples stop paying for themselves on frontier models** — Anthropic's own Claude Code team says worked examples in a system prompt are no longer best practice on Fable 5 / Opus 4.8-class models; dropping them cut Claude Code's own system prompt by 80% `[hypothesis — one team's internal report, unreplicated]` → [Cat & Thariq fireside chat, 2026-07-21](https://simonwillison.net/2026/Jul/21/cat-and-thariq/)
- **Skills-vs-MCP economics** — skill ≈ 60 tokens at rest, MCP schemas can eat 10–20% of the window; prototype with MCP, convert to a skill → `guides/context-and-subagents.md`
- **Active context moves** — /context audit, /clear on task switch, /compact only at intentional phase breaks, persisted docs are the real memory; Claude Code ≥v2.1.218 now does one of these automatically — `/code-review` and any skill declaring `context: fork` run as a background subagent by default instead of filling the conversation (`background: false` opts out) → `guides/context-and-subagents.md`
- **Mid-conversation system messages (GA, Messages API)** — `role: "system"` messages can now be sent mid-conversation (Opus 4.8+/Fable 5/Mythos 5), changing instructions during a long-running session without breaking the prompt-cache prefix — the raw-API-tier analogue of the context moves above; **mid-conversation tool changes** (beta, same model set + Opus 5) extend the same trick to the tool list — add/remove tools between turns without breaking the cache → [platform release notes, 2026-07-15](https://platform.claude.com/docs/en/build-with-claude/mid-conversation-system-messages) · [2026-07-24 entry](https://platform.claude.com/docs/en/release-notes/overview)
- **Subagents isolate volume and bias** — model tiering: expensive parent, cheap children → `guides/context-and-subagents.md`

---

## 3. Pipeline / workflow

- **Grilling** — one-question-at-a-time alignment with a recommended answer; batch questions get rubber-stamped → `tooling/skill-templates/grilling.md`
- **PRD as destination document** — Out-of-Scope defines done and powers scope-creep detection at review → `workflows/idea-to-ship.md`
- **TDD red-green-refactor** — failing test first so the agent can't ratify what it already built → `tooling/skill-templates/tdd.md`
- **Two-axis review** — Standards + Spec, parallel fresh subagents, never merged; confidence scoring 0–100, surface ≥75, false-positive kill-pass → `tooling/skill-templates/two-axis-review.md`
- **Handoff doc kills doc rot** — fold planning docs in and delete them once the ticket ships → `tooling/skill-templates/handoff.md`
- **Debugging loop** — build the red-capable feedback loop FIRST; 3–5 ranked falsifiable hypotheses; one variable at a time; regression test before fix; post-mortem feeds the mistake log → `workflows/debugging-loop.md`
- **Test-suite-as-trust-boundary** — at a scale where per-instance review is impossible (mass AI-driven generation/rewrites), the existing test suite becomes the sole merge gate, and review targets systemic flaws in the *generator* rather than patching individual failures — fix the pipeline, not the output → `workflows/debugging-loop.md`
- **Codebase health** — design vocabulary (deep module, seam, locality), deletion test, testability by design; output = ready-to-paste tickets, never code → `workflows/codebase-health.md`
- **Fresh session per issue** — keep each unit inside the smart zone → `workflows/idea-to-ship.md`
- **Venture pipeline mirrors the dev pipeline** — idea → grill → research → verify → position → plan → gate reviews → dev handoff; gates pre-committed before data arrives → `workflows/venture-pipeline.md`
- **Claims discipline** — every market/factual claim is `[verified — source]` or `[hypothesis]`; external AI pastes stay unverified until an adversarial claim-verifier passes them; the tag contract is what makes role-agent outputs composable → `catalog/business-agents.md`
- **Past-behaviour validation** — interview for what someone *did* ("walk me through your last filing"), never what they *would* do; hypothetical questions are free to say yes to and predict nothing. Corollaries: interview whoever feels the pain (often not leadership), and build the gates on what interviewees *describe* rather than on secondary statistics → `research/2026-08-02_ngo-project-validation.md`
- **Grade fan-out strands separately** — source authority varies *within* one research run; route decisions around the weak strands instead of averaging them into a single confidence → `research/2026-08-02_ngo-project-validation.md`

---

## 4. Skills & tooling mechanics

- **The mechanism decision** — skill vs command vs subagent vs hook vs MCP vs memory in one table; "whenever X do Y" = hook, not a preference → `guides/skills-commands-agents-hooks.md`
- **Skill economics** — user-invoked costs cognitive load, model-invoked costs context load (description always resident) → `guides/writing-skills.md`
- **Frontmatter levers** — allowed-tools, model (haiku for mechanical, inherit for judgment), disable-model-invocation, argument-hint → `guides/writing-skills.md`
- **Progressive disclosure** — metadata (~100 words, always loaded) → SKILL.md body (<500 lines, on invocation) → bundled resources (on demand) → `guides/writing-skills.md`
- **Skill-testing loop** — dual-baseline eval (with/without in parallel), benchmark.json (pass_rate/time/tokens), repeated-helper-script → bundle it → `guides/writing-skills.md`
- **Router-skill pattern** — when user-invoked skills outgrow memory (6+) → `guides/writing-skills.md`
- **Leading words anchor behavior** — front-load the trigger word in descriptions in fewest tokens → `guides/writing-skills.md`
- **Failure modes** — premature completion, duplication, sediment, sprawl, no-op → `guides/writing-skills.md`
- **Tool discipline** — route via CONTEXT-style routers before opening files; Glob/Grep over shell find/grep; Read before Edit → `guides/claude-code-tools.md`
- **Vendoring** — never link, vendor with VENDORED.txt + stripped .git; neutralize live config (dot-claude/, UPSTREAM-CLAUDE.md) → `CLAUDE.md`
- **Teach-on-demand beats always-on teaching** — output styles (Explanatory/Learning) tax every turn and can't toggle mid-session; a user-invoked skill teaches only when asked. 3-level ladder: analogy → how it works here → trade-off → `tooling/skill-templates/explain.md`

---

## 5. Hooks & automation

- **Hooks = the only guaranteed behavior** — harness-run, not model-run; ~30-event surface → `guides/skills-commands-agents-hooks.md`
- **Verified hook mechanics** — UserPromptSubmit's field is `prompt` (silent wrong-field bug = zero logs); UserPromptExpansion + SessionEnd exist; PreToolUse denies via `permissionDecision:"deny"` JSON; PostToolUse replaces output via `updatedToolOutput`; Stop fires EVERY response end → sentinel or byte-offset patterns → `guides/skills-commands-agents-hooks.md`
- **Hooks never see real token %** — mechanical proxies only (files read, re-reads, compaction events) → `tooling/usage-logging-hooks/README.md`
- **Warn-don't-block default** — blocking only when lossless (redundant-read deny, test-output filtering) with escape-hatch env vars → `tooling/usage-logging-hooks/README.md`
- **A hook that has never fired is a bug signal** — not proof of quiet behavior → `guides/skills-commands-agents-hooks.md`
- **hookify** — declarative no-code guardrail authoring → `references/claude-code-plugins/INDEX.md`
- **/goal: native loop-until-condition (Stop-hook + Haiku transcript-judge, ≥v2.1.139)** → `research/2026-07-05_fable5-compound-stack-verification.md`
- **Routines: cloud scheduled agents (laptop-closed; Schedule/API/GitHub triggers) vs local scheduled tasks — choose by where the repo lives** → `research/2026-07-05_fable5-compound-stack-verification.md`

---

## 6. Multi-agent patterns

- **Subagent roster** — explorer (volume), reviewer (objectivity), domain-reference (repeated external lookups) — each on the cheapest adequate model → `catalog/agents.md`
- **Fan-out/fan-in** — N cheap researchers → one smart synthesizer; ~15× tokens, worth it for research breadth only (Anthropic 90.2% finding), not coding → `guides/context-and-subagents.md`
- **Stochastic consensus (= self-consistency, Wang 2022)** — works for checkable answers, mere dedup for open-ended → `tooling/skill-templates/stochastic-consensus.md`
- **Debate: REJECTED** — underperforms consensus at equal cost; tombstoned so it isn't re-proposed → `catalog/agents.md`
- **0.95^N compound failure** — failure probability compounds with swarm size; don't parallelize one unit of work — two independent worktree sessions max; the same math now has a **depth** axis too — Claude Code ≥v2.1.219 defaults nested subagents to spawn depth 3 (was 1, `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`) — a deep review-panel/business-agent roster compounds failure the same way a wide one does → `catalog/agents.md`
- **Maturity vs Evidence** — "have I run it" vs "has the field validated it" — score patterns on both axes independently → `catalog/README.md`
- **Orchestrator-workers + evaluator-optimizer** — cookbook patterns (vendored notebooks) → `references/anthropic-cookbook-agent-patterns/`
- **Dynamic Workflows: Claude authors its own orchestration harness at runtime (fan-out-synthesize, adversarial verification)** — `/config` (≥v2.1.202) exposes an advisory small/medium/large size guideline, not an enforced cap → `research/2026-07-05_fable5-compound-stack-verification.md`
- **Business role-agent family** — six scoped roles (strategy/PM/marketing/UX/research/verification) with explicit "Refuses to do" fences; project type is an onboarding axis, not a tier → `catalog/business-agents.md` · `tooling/agent-templates/`
- **Specialist review panel** — split review into focused axes (design/principal-engineer, language idioms, standards, spec) in fresh parallel contexts, never merged; pick 2–3 axes per diff (0.95^N), each strictly above what tooling enforces; SOLID is a lens not a checklist — depth beats decomposition (SRP-shrapnel warning) → `catalog/agents.md` · `tooling/agent-templates/design-reviewer.md`

---

## 7. Self-improvement loops

- **Capture automatic, apply human-gated** — the repo's standing philosophy → `tooling/usage-logging-hooks/README.md`
- **Usage ledger** — append-only JSONL discriminated by kind; /retro reads it on request → `tooling/usage-logging-hooks/README.md`
- **Per-iteration loop** — warn/compaction events auto-queue as [CANDIDATE] lessons (Stop hook, byte-offset) → /retro-lite human-gated promotion ([DONE]/[SKIPPED]) → `tooling/usage-logging-hooks/README.md`
- **Manual loop (Saraev)** — per-task "how could this have been faster?" + cross-session pattern promotion to global CLAUDE.md → `research/2026-06-28_auto-research-and-harnesses.md`
- **Auto-research (Karpathy)** — metric + fast change lever + fast assessment; loop speed compounds; the human is removed → `research/2026-06-28_auto-research-and-harnesses.md`
- **Harness** — everything wrapping the LLM; don't over-build before feeling the vanilla limits → `research/2026-06-28_auto-research-and-harnesses.md` · `research/2026-07-19_harness-and-loop-engineering.md`
- **Harness engineering (named discipline, Feb 2026)** — Agent = Model + Harness; mistake→permanent-fix (Hashimoto), "humans steer, agents execute" (OpenAI); our RecurringMistakes+hooks loop independently converged with the coining post → `research/2026-07-19_harness-and-loop-engineering.md`
- **Iterative simplification (harness pruning)** — every harness component encodes an assumption about what the model can't do; re-test per model generation and DELETE scaffolding it no longer needs — the decay side of don't-over-build → `research/2026-07-19_harness-and-loop-engineering.md`
- **Context resets beat compaction** — structured handoff + clean slate > summarize-in-place; "context anxiety" = premature wrap-up near perceived limits (~147–152k cliff observed in ralph) → `research/2026-07-19_harness-and-loop-engineering.md`
- **Loop taxonomy** — axes: what iterates · inner (converge artifact) vs outer (improve system) · gate · judge-sees (tools vs transcript) · state location; autonomy is safe ≈ judge-with-tools AND state-on-disk; NO loop without an explicit stop condition + budget — now platform-enforced in Claude Code ≥v2.1.212 (session-wide default caps: 200 subagent spawns, 200 WebSearch calls; `/clear` resets; overridable via `CLAUDE_CODE_MAX_SUBAGENTS_PER_SESSION`/`CLAUDE_CODE_MAX_WEB_SEARCHES_PER_SESSION`) → `research/2026-07-19_harness-and-loop-engineering.md`
- **12-factor-agents** — production principles checklist (own prompts/context/control-flow, tools-as-structured-output, small focused agents, stateless reducer); 10/12 already native or practiced here, gaps (#5 unify-state, #6 pause/resume) are custom-harness-tier → `research/2026-07-19_harness-and-loop-engineering.md`
- **Evaluate the designer, not just the implementer** — verify a plan's load-bearing claims against official docs before building → `research/journal.md`
- **Web automation: 3 tiers** — HTTP/browser/computer-use; prototype general, harden cheap → `guides/web-automation-tiers.md`
- **Outcome-grader loop: define outcome + rubric, independent grader in fresh context, iterate to max_iterations (/goal local · Outcomes cloud)** → `research/2026-07-05_fable5-compound-stack-verification.md`
- **Vision maker→verifier: screenshot the rendered UI, fresh vision agent grades vs the goal — generator never grades its own work** → `research/2026-07-05_fable5-compound-stack-verification.md`

---

## 8. Domain workflows (NAO / Salesforce)

- **7-step canonical flow** — mapped onto sf-nao-admin's concrete commands; where it's sharper than vanilla Pocock → `workflows/nao-pipeline-mapping.md`
- **Two-tool governance** — Claude owns planning/implementation/scratch-verify, Devin owns 100% of git/packages/sandboxes → `workflows/nao-admin-dev-loop.md`
- **Org-safety tiers** — scratch = free deploy · qa = confirm every time, never delete · uat = never → `workflows/nao-admin-dev-loop.md`
- **Company visibility** — local-only .claude/, no tool names in committed files → `improvements/nao-pipeline-improvements.md`
- **Living backlog** — the prioritized list of pipeline improvements (built + open) → `improvements/nao-pipeline-improvements.md`

---

## Maintenance

Grown by /sync-context Step 6: net-new concepts only, prune superseded (this is a map, not a log).
STATE.md "Key conclusions" is the currency-filtered subset of this file — active conclusions only.
When a concept is superseded, remove or correct the line here rather than appending a replacement.
