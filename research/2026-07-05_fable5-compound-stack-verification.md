# Fable 5 "Compound Stack" — verified against official docs

An X thread (@0xCodez, "14-step Fable 5 compound stack") claimed a stack of new
Fable 5 features and numbers. Rather than adopt it wholesale — the usual
listicle failure mode — we checked every claim against the actual Claude Code
docs, Anthropic blog posts, and the launch post, and only adopted what survived
*and* fit our actual constraints (no remote on this repo, `sf-nao-admin`'s
company-visibility + Devin-owns-git rules). Same discipline as the
[2026-06-28 harness note](2026-06-28_auto-research-and-harnesses.md): interesting
source, verify before folding in.

---

## Claims table

| Claim | Verdict | Official source | Reality-check |
|---|---|---|---|
| `/goal` loop-until-condition | VERIFIED | [code.claude.com/docs/en/goal](https://code.claude.com/docs/en/goal) (≥v2.1.139) | Session-scoped; a Stop-hook wrapper where a Haiku judge reads the transcript each turn and returns pass/fail. Judge cannot run tools. One active goal per session — not a general autonomy switch. |
| "Outcomes" in Claude Managed Agents | VERIFIED | [claude.com/blog/new-in-claude-managed-agents](https://claude.com/blog/new-in-claude-managed-agents) + platform.claude.com cookbook | Cloud-only: `user.define_outcome` (description + rubric text\|file + `max_iterations` ≤20, default 3). Grader runs in a fresh, separate context each iteration with the writer's full toolset — same maker/checker split as `/goal`, just cloud-hosted. |
| Dynamic Workflows | VERIFIED | [claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code](https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code) | Claude authors its own multi-agent orchestration harness at runtime. Named patterns: fan-out-and-synthesize, adversarial verification (a skeptic agent per producer, contexts never shared). |
| Routines | VERIFIED | [code.claude.com/docs/en/routines](https://code.claude.com/docs/en/routines) | Saved configs on Anthropic cloud infra — run laptop-closed. Triggers: Schedule, API, GitHub events, combinable. |
| Vision maker→verifier loop for UI | VERIFIED | [code.claude.com/docs/en/best-practices](https://code.claude.com/docs/en/best-practices) | "a browser screenshot compared against a design"; explicit engineering guidance that the generator must never grade its own work. |
| "Design loops, don't steer directly" framing | VERIFIED (direct quote) | Anthropic | *"Rather than directly prompting and steering Fable 5, it's often better to design loops that let the model self-correct in response to environment feedback (e.g., /goal or Outcomes) and manage its own context (e.g., via memory)."* |
| Launch facts (date, pricing, fallback model) | PARTIAL | [anthropic.com/news/claude-fable-5-mythos-5](https://anthropic.com/news/claude-fable-5-mythos-5) | June 9 2026, Mythos-class, $10/$50 per Mtok, safety classifiers fall back to **Opus 4.8** — thread said 4.7, which is wrong. >95% of sessions never trigger the fallback at all. |
| "Fail→Investigate→Verify→Distill→Consult" 5-stage memory progression | FABRICATED | none found | No official source names this progression. Continual Learning Bench itself is real (Fable 5 beat Opus/Sonnet with file-based memory, per the launch post) — the thread took a real benchmark and bolted an invented taxonomy onto it. |
| "73% verification coverage vs Opus 4.7 ~17%" | FABRICATED | none found | No such benchmark exists in any cited source. A specific-sounding number with no citation is the tell. |

7 of 9 rows fully verified, 1 partial (right feature, wrong model number), 2
fabricated outright.

---

## Already-built mapping

Most of what's real in the thread, we'd already built here under different
names — the thread mostly re-labeled patterns already live in this repo:

| Thread layer | Our artifact |
|---|---|
| Layer 3 memory | `STATE.md` / `research/journal.md` / `CONCEPTS.md` + auto-memory |
| Layer 4 self-improvement | usage ledger + `pending-lessons.md` + `/retro-lite` / `/retro` |
| "Verifier beats self-critique" | `/review-diff` two-axis review + validation kill-pass |
| Model routing matrix | delegate-by-judgement + model-pinned subagents (haiku/sonnet tiers) |
| Routines-shaped need | local scheduled task `ai-research-weekly-digest` |

---

## Decisions

**Adopt:**
- `/verify-ui` in `sf-nao-admin` — revives backlog item #20 (deferred browser
  console verification), but scoped: two-mode vision verification (manual
  screenshot by default, browser-tool capture when connected), a fresh Sonnet
  verifier grading against ticket acceptance criteria. This is the vision
  maker→verifier pattern, applied narrowly instead of reviving the full
  Playwright harness.
- Documenting native `/goal` as an available option for loop-until-condition
  work, alongside our existing hand-rolled loops.
- STATE-template `Verified facts` / `Open failures` split — this verification
  exercise itself is the reason: distinguishing "checked against reality" from
  "tried, not resolved" is exactly the discipline that would have caught the
  two fabricated claims faster if it had existed as a template section already.

**Document-only (not deployed):**
- Routines + Outcomes/CMA. Both are cloud features requiring Anthropic-hosted
  infra. `ai-research` has no remote to attach them to, and `sf-nao-admin`'s
  company-visibility rule plus Devin-owns-git constraint forbid attaching
  cloud infra to that repo regardless. Local scheduled tasks remain the
  correct mechanism for both repos as they stand today — documented as
  "here's what exists, here's why we're not using it yet," not adopted.

**Rejected:**
- The thread's 4-layer restructure — already implemented here, under
  different names (see mapping table above). Restructuring to match the
  thread's naming would be a rename with no functional gain.
- Days-long autonomy for banking work — `sf-nao-admin`'s org-safety tiers and
  the Devin git-gate require human checkpoints by design; multi-day unattended
  runs are the opposite of that design intent, not a gap to close.

---

## Closing lesson

7 of 9 claims checked out (with one factual slip on a model name) — genuinely
better hit rate than most listicles, and four of the verified claims are
real, new, native features worth knowing about. But the two fabricated claims
were stated with the same confident precision as the verified ones — a
specific percentage and a named 5-stage taxonomy, no hedging, no citation.
Precision is not evidence. This is exactly why the digest pipeline verifies
before promoting: a plausible-sounding number is the failure mode that a
"sounds right" filter will never catch, and only a source check will.
