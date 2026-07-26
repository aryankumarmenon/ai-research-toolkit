# Harness & loop engineering — the field catches up (2026-07-19)

Sequel to [2026-06-28_auto-research-and-harnesses.md](2026-06-28_auto-research-and-harnesses.md)
(which defined *harness* = "everything that wraps the LLM but is not the LLM")
and [2026-07-05_fable5-compound-stack-verification.md](2026-07-05_fable5-compound-stack-verification.md)
(the native loop features: /goal, Outcomes, Dynamic Workflows). This note adds
what those predate: between Jul 2025 and Feb 2026 the industry **named the
discipline**, converged on prescriptive design principles, and produced a
principles framework (12-factor-agents). Much of it independently validates
what this repo already built — which is itself evidence worth recording.

---

## 1. The discipline gets named (timeline, all primary-source dated)

| When | Who | What |
|---|---|---|
| 2025-07-14 | Geoffrey Huntley — [ralph](https://ghuntley.com/ralph/) | The brute-force loop: `while :; do cat PROMPT.md \| claude-code; done` — fresh context per iteration, state on disk. "Deterministically bad in an undeterministic world." |
| 2025-11-26 | Anthropic — [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) | Harness = what lets agents work across context windows on hours/days tasks. Two-agent shape (initializer + coding), feature-list JSON, progress files, incremental one-feature-at-a-time, e2e browser verification, clean-state commits. |
| 2026-02-05 | Mitchell Hashimoto — [My AI Adoption Journey](https://mitchellh.com/writing/my-ai-adoption-journey) | Coins **harness engineering**: "anytime you find an agent makes a mistake, you take the time to engineer a solution such that the agent never makes that mistake again." Two forms: doc-line-per-error (AGENTS.md; Ghostty errors "almost completely resolved" `[author-reported]`) + programmed verification tools. |
| 2026-02-11 | OpenAI — [Harness engineering: leveraging Codex in an agent-first world](https://openai.com/index/harness-engineering/) (Ryan Lopopolo) | Formalizes: the discipline of building the environment/scaffolding/feedback loops for agent-driven development — "the infrastructure of intent, constraints, and context." Motto: **"Humans steer. Agents execute."** Evidence: internal beta, ~1M lines, zero hand-written code, ~1/10th the time `[self-reported, OpenAI — no external audit]`. |
| 2026-03-24 | Anthropic — [Harness design for long-running application development](https://www.anthropic.com/engineering/harness-design-long-running-apps) | The maturest design doc: separation of concerns, context resets > compaction, external evaluation, **iterative simplification**. Quantified: harnessed run $9 vs $200 naive, naive shipped broken core features `[Anthropic self-reported, n=1]`. |
| Feb–Jun 2026 | Community wave | LangChain condenses to **"Agent = Model + Harness"** `[via secondary coverage]`; awesome-lists, surveys, and vendor guides proliferate. |

**Mapping to our existing line:** the field's definition ⊇ ours. The 2026-06-28
"everything wrapping the LLM" line stands; what's new is the *prescriptive*
layer (§2) and the loop being treated as a first-class design object (§4).

---

## 2. Harness design principles (prescriptive — distilled across all sources)

1. **Mistake → permanent fix** (Hashimoto). Every observed failure becomes a
   structural impossibility: a doc line, a hook, a verification tool. *This is
   exactly our `RecurringMistakes.md` + warn-hooks + `/retro-lite` promotion
   loop* — built here 2026-07-02→04, independently converging with the coining
   post. Validation, not novelty.
2. **External evaluation — never self-graded** (Anthropic Mar 2026). Named
   mechanism: **self-evaluation leniency** — models praise their own mediocre
   output. Separate generator from evaluator; make subjectivity gradable via
   concrete rubrics. *Ours: two-axis review, review panel, vision
   maker→verifier, /goal's separate judge.* Also names **sprint contract
   negotiation**: generator+evaluator agree success criteria *before* work —
   our grilling/PRD gate is the human-in-the-loop version.
3. **Context resets beat compaction** (Anthropic Mar 2026). Structured
   handoff + clean slate outperforms summarize-in-place; names **context
   anxiety** — models rush to premature conclusions near perceived context
   limits. *New to us as a named mechanism* — our handoff-doc + fresh-session
   discipline was the right call for a reason we can now cite; ralph's
   observed quality cliff at ~147–152k tokens `[author-reported]` is the same
   phenomenon measured.
4. **Iterative simplification** (Anthropic Mar 2026). "Every component in a
   harness encodes an assumption about what the model can't do" — re-test
   those assumptions each model generation and **delete** scaffolding the
   model no longer needs (their v2 removed sprints once Opus 4.6 handled
   planning). *Genuinely new principle for us*: harness pruning as a
   scheduled activity, the deletion-test applied to our own `.claude/`
   tooling. Pairs with the existing "don't over-build before feeling vanilla
   limits" (build side) — this is the decay side.
5. **State on disk, not in context** (ralph; Anthropic Nov 2025's
   feature-list JSON + progress files). The context window is ephemeral
   working memory; the repo is the durable state. *Ours already:* STATE.md /
   journal / handoff docs / ralph-wiggum's state file.
6. **The harness constructs the prompt; the user only seeds it** (vendored
   [why-harness-is-important](../references/claude-code-best-practice/reports/why-harness-is-important.md),
   now finally distilled). User's ~6–60 tokens (prompt-a) vs the ~5–50k the
   model actually sees (prompt-b); 10 capabilities prompts categorically
   can't replicate (context isolation, enforced tool restrictions, hooks,
   model routing, parallelism, persistence…). Its formula is the compact
   summary of this whole note: **`Output = f(effective context, model
   capability, iteration loop)`** — context engineering, model choice, and
   loop engineering as the three levers.
7. **Feedback loops are the highest-leverage tooling** (recurring across
   OpenAI/community coverage, often as "verify-your-work doubles-to-triples
   quality" `[hypothesis — widely repeated, no primary benchmark located]`).
   Consistent with our task→do→verify root principle.

---

## 3. 12-factor-agents, mapped to this repo

[humanlayer/12-factor-agents](https://github.com/humanlayer/12-factor-agents)
(Dex/HumanLayer, 24.4k★) — the closest thing to a principles checklist the
field has. Philosophy matches ours: small modular concepts over heavyweight
frameworks. Factor → where we already stand:

| # | Factor | Us |
|---|---|---|
| 1 | NL → tool calls | harness-native (Claude Code) |
| 2 | Own your prompts | CLAUDE.md/skills discipline; no framework defaults |
| 3 | Own your context window | context-engineering guide; pointer-style memory files |
| 4 | Tools are structured outputs | harness-native |
| 5 | Unify execution + business state | **gap** — SDK-tier concern, N/A until we build a custom harness |
| 6 | Launch/pause/resume simple APIs | partial: handoff docs = manual pause/resume — narrowing: Claude Code `/fork` (≥v2.1.212) forks a conversation into a new *background* session while preserving the parent, a native (if still manual-trigger) pause/branch primitive |
| 7 | Contact humans via tool calls | capture-automatic/apply-human-gated is our stronger form |
| 8 | Own your control flow | which-step + pipeline chains; loops chosen deliberately |
| 9 | Compact errors into context | filter-test-output hook does exactly this |
| 10 | Small, focused agents | scope-fenced role agents; 0.95^N cap |
| 11 | Trigger from anywhere | scheduled tasks; Routines documented-only |
| 12 | Stateless reducer | ralph's shape; our scheduled digest (fresh context + disk state) |

Ten of twelve either native or already practiced; the two gaps (5, partially
6) only bite when building a custom harness — earmarked with the enterprise
side-project (STATE thread #0).

---

## 4. Loop taxonomy — our eight loops on one map

The repo runs/documents ~8 loops, scattered. One table, four axes:

| Loop | What iterates | Inner/Outer | Gate | Judge sees | State lives |
|---|---|---|---|---|---|
| [Debugging loop](../workflows/debugging-loop.md) | hypothesis → probe | inner | human | tools (red-capable cmd) | context + repro |
| tdd red-green | test → code | inner | autonomous per-behavior | tools (test run) | repo |
| [/goal](2026-07-05_fable5-compound-stack-verification.md) | whole attempt | inner | autonomous ≤ goal | **transcript only** | context |
| Outcomes (cloud, doc-only) | whole attempt | inner | autonomous ≤ max_iter | tools (fresh ctx) | cloud workspace |
| [Vision maker→verifier](2026-07-05_fable5-compound-stack-verification.md) | render → grade | inner | autonomous | screenshot | scratch org |
| [ralph-wiggum](../references/claude-code-plugins/INDEX.md) | one unit of work | outer | autonomous (promise/max) | tools | **disk only** |
| [Evaluator–optimizer / usage-ledger](../catalog/agents.md) | the *tooling* | outer | **human-gated** (/retro-lite) | ledger | disk |
| [Auto-research](2026-06-28_auto-research-and-harnesses.md) | the *system* | outer | autonomous | metric | disk |
| Saraev manual loop | habits/rules | outer | human | conversation | CLAUDE.md |
| [Skill-testing loop](../guides/writing-skills.md) | a skill | outer | human | benchmark.json | disk |

Reading the axes: **inner loops** converge one artifact; **outer loops**
improve the system that makes artifacts. Autonomy is safe roughly when *judge
sees tools* (can independently verify) AND *state lives on disk* (a bad
iteration is recoverable); /goal is the deliberate exception (transcript-only
judge → "not a general autonomy switch"). Human gates belong where taste or
org-safety outweigh speed — our qa/uat tiers, promotion into rules.

---

## 5. Loop failure modes (now with names)

- **Reward-hacking the check:** ralph's "placeholder implementations —
  models default to minimal code satisfying the reward function"; same
  species as grader-gaming an outcome rubric. Counter: judge-with-tools,
  adversarial verification (Dynamic Workflows), test-suite-as-trust-boundary
  only when the suite predates the loop.
- **Context anxiety / clipping:** premature wrap-up near perceived limits
  (named, Anthropic) and the ~147–152k quality cliff ralph observed. Counter:
  resets-with-handoff, one-unit-per-iteration.
- **False completion:** "premature victory declarations" (Anthropic Nov 2025
  failure table) — counter: feature-list JSON with per-item `passing:false`,
  e2e verification before marking done.
- **Search non-determinism:** ralph — grep says "not implemented", agent
  re-implements. Counter: explicit "don't assume not implemented" + state
  files as the source of truth.
- **Broken-state wakes:** loop resumes on a non-compiling repo. Counter:
  clean-state commits per iteration (Anthropic), or ralph's manual reset.
- **Cost blow-up / no stop:** ralph runs infinite without
  `--completion-promise`/`--max-iterations`; Outcomes caps at ≤20. Rule:
  **no loop without an explicit stop condition + budget.** Claude Code
  ≥v2.1.212 now enforces a version of this by default at the platform level
  (not just as tooling advice): 200 subagent spawns and 200 WebSearch calls
  per session, reset by `/clear`, overridable via
  `CLAUDE_CODE_MAX_SUBAGENTS_PER_SESSION` / `CLAUDE_CODE_MAX_WEB_SEARCHES_PER_SESSION`.

---

## 6. What transfers where

- **NAO / sf-nao-admin:** inner loops with tool-judges (tdd, verify-scratch,
  vision-verifier) and human-gated outer loops (retro-lite) — unchanged;
  org-safety tiers keep long-autonomy out by design. New adoptable ideas:
  **iterative simplification** (schedule a harness-pruning pass over
  `.claude/` — the 2026-07-18 token trim was the first instance, now it has
  a name and a cadence argument) and **context-anxiety** as the citable
  reason behind the existing handoff discipline.
- **Enterprise side-project (STATE thread #0):** the long-autonomy stack —
  Outcomes-style iterate-until-pass, ralph-shaped outer loops,
  initializer+coding two-agent harness, 12-factor gaps #5/#6 — all land
  there, where no org constraints apply.

## 7. SOURCES.md candidates (listed only — not applied this round)

If harness/loop stays a live topic: [ghuntley.com](https://ghuntley.com)
(origin essays, high signal), [humanlayer/12-factor-agents](https://github.com/humanlayer/12-factor-agents)
(watch releases/commits), [Cognition blog](https://cognition.ai/blog)
(already cited in catalog for don't-build-multi-agents). The Anthropic
engineering blog (already Tier 1) published both harness posts — the digest
would have caught the Mar one had it existed then.

## Sources

All linked inline. Claims tagged `[self-reported]`/`[author-reported]`/
`[hypothesis]` where no independent verification exists. Secondary coverage
(awesome-lists, vendor guides, surveys) was used only for discovery, not as
evidence.
