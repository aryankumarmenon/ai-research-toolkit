# 2026-08-02 — Open-source contribution plan (Aug → Dec 2026)

Replaces the NGO side-project direction (see
[2026-08-02_ngo-project-validation.md](2026-08-02_ngo-project-validation.md),
still valid as research, no longer the active plan). Goal restated by the user:
**open-source contribution / technical visibility that helps in interviews**,
across the NestJS-TypeScript backend track *and* AI-agent tooling, on weekends
through December (~20 weekends, ~150–200 hours).

Produced from a second four-agent Sonnet fan-out on 2026-08-02: TS/Node
contribution targets · AI-agent tooling ecosystem · OSS-to-hiring conversion ·
AI-assisted contribution norms. All repo metrics below were measured live via
`gh api` / `gh search` on 2026-08-02 and **will drift** — re-measure before
acting on any of them.

---

## 1. The reframe — read this before anything else

The hiring-conversion research was deliberately instructed to hunt for
disconfirming evidence, and it found a lot. The honest summary:

- **The modal outcome of 150–200 hours of OSS work is no measurable hiring
  effect.** That is the most likely single result, not a pessimistic edge case.
- Multiple hiring-side practitioners state they never open a candidate's
  GitHub at all — one reported interviewing 150+ people and never looking once
  `[verified — Blind, HN threads]`. At larger companies the real gate is
  DSA/system-design rounds plus a resume screen for degree and prior employer.
- The people who *were* hired through OSS were mostly **maintainers of
  recognisable projects**, not contributors — a status not reachable in one
  part-time season `[verified — HN 43414821]`.
- The agreed ceiling among hiring-side commenters is **tiebreaker between
  otherwise-similar candidates**. Not a door-opener.
- A structural critique also stands unrebutted: hiring on OSS favours people
  with free time, which correlates with privilege
  `[verified — Duane O'Brien, GitLab blog, 2018 — dated but unrebutted]`.

**What survives, and what the plan therefore optimises for.** What registers
with the minority who *do* look is not volume — it is evidence of judgment:
sustained engagement with one project, and how you discuss design tradeoffs and
maintainer pushback. That aligns with the separate finding that the hiring
signal has moved from "can you produce code" to "can you judge code."

> **The asset is the interview conversation, not the merged PR.** A contribution
> with real review back-and-forth gives you something concrete and honest to
> narrate — and that value holds whether or not anyone ever clicks your GitHub.

So the target is **two or three PRs deep enough to argue about for ten
minutes**, plus writing that shows the reasoning. Explicitly *not* targets:
contribution counts, streaks, a green graph (gameable and read as noise), or a
list of typo fixes (can read as negative).

**India-specific signal is an open gap.** The agent could not reach
r/developersIndia or r/cscareerquestionsIN, and indexed India-specific content
was dominated by SEO farms publishing unsourced statistics, correctly refused as
sources. Worth 20 minutes of manual browsing before committing five months.

---

## 2. Target selection — fame is anti-correlated with tractability

The single most actionable finding. Picking the wrong repo is the main failure
mode, and in maintainer-starved repos the failure mode is not rejection but
**silence**.

### Avoid (measured 2026-08-02)

| Repo | Evidence |
|---|---|
| **class-validator** | **0 PRs merged in 60 days; no commit since Feb 2026.** Effectively unmaintained — and it is NestJS's default validation library |
| **TypeORM** | 11 `good first issue` labels, but **0 of the last 100 merged PRs** came from a first-time contributor; 156 open PRs vs 32 merged/60d; labels mostly 2017–2022 |
| **Drizzle ORM** | 568 open PRs vs 23 merged/60d despite popularity |
| **BullMQ** | Merge volume dominated by bots/core team; outside PRs from 2022–23 still open with 0–1 comments |
| **Pino** | 8 GFI / 5 help-wanted, all stale (2022–2024); only 13 merged/60d |
| **LlamaIndexTS** | `archived: true`, last push 2026-03-11 — confirmed dead |
| **Ragas** | No commits since 2026-02-24; Python-only |
| **Braintrust** | Core is closed-source SaaS; only a thin proxy is open |

### Healthy (measured 2026-08-02)

| Repo | Evidence | Note |
|---|---|---|
| **Vitest** | 166 merged/60d vs 77 open; sampled external PR merged in **35 min** | Best throughput-to-backlog ratio measured |
| **Fastify** | 79 merged/60d vs 71 open; substantive review comments | Same engine family as Nest underneath |
| **NestJS** | Real first-timer merges: 28-line fix merged in 2 days; 263-line fix took 6 weeks with **7 review comments** | PR volume is largely dependency-bot noise |
| **MCP TypeScript SDK** | 13k★, GA (v1.30.0, 2026-07-27), external PRs merging weekly, 7 `help wanted` | Writing *another* MCP server is commodity; SDK/registry internals are not |
| **Promptfoo** | 24k★, TS/Node-native core, 100+ PRs/60d | Evals — named elsewhere as the AI-track differentiator |
| **OpenLLMetry** | 11 open `help wanted` vs only 13 merged/60d | Genuinely understaffed = attention available; OpenTelemetry-backed so it won't evaporate |
| **Mastra** | 27k★, **31 unique PR authors** in a 60-day sample | Author diversity is the tell — they merge outsiders |
| Vercel AI SDK | 26k★ but only **10 unique authors** in the same sample | Vercel core dominates merges — hard to land something meaningful |

**Read Mastra vs Vercel AI SDK carefully.** Near-identical star counts; one
merges from 31 different people, the other from 10. That ratio should drive
target selection far more than fame does.

No CLA/DCO friction found anywhere in this set — not a rejection cause here.

### What real first PRs look like

Sampled merged PRs from contributors with no prior history:

- nestjs/nest #17335 — 28 additions, 2 files, regex bug fix, merged in 2 days.
- nestjs/nest #17040 — 263 additions, 6 files, shutdown-hook fix, **7 review
  comments over 6 weeks** of iterative back-and-forth.
- vitest-dev/vitest #10495 — 29 additions, merged in 35 minutes.

**The 6-week/7-comment PR is the one worth having.** The 35-minute merge gives
you nothing to narrate. Optimise for review depth, not merge speed.

### Why first PRs fail here

- Picking a `good first issue` that is actually 2–4 years stale and contentious
  (rampant in TypeORM and Pino — the label was never cleaned up).
- Large unscoped PRs opened without prior issue discussion — both Nest's and
  Fastify's CONTRIBUTING guides explicitly ask for the discussion first.
- Landing in a maintainer-starved repo and waiting forever for a review.

---

## 3. The AI-assisted contribution line — where it actually sits

Policy **fractured** in 2026; it did not converge. There is no single norm and
**each project's own CONTRIBUTING.md is the only ground truth.**

- ~120+ projects ban AI-generated contributions outright (Gentoo, NetBSD, Zig,
  QEMU, Servo, Clojure, musl…).
- ~80+ allow with mandatory disclosure and full human accountability (Linux
  kernel, LLVM, Django, Kubernetes, Apache).
- A handful allow silently (CPython, PyTorch, Firefox, ruff/uv).
- Unresolved: Rust (competing RFCs), Node.js (contentious after a 19k-line
  AI-heavy PR in Jan 2026), Debian (General Resolution mid-vote as of Aug 2026).

**Two findings that directly kill the "agent auto-fixes good-first-issues" idea:**

1. **LLVM explicitly forbids AI assistance on issues labelled `good first
   issue`** — specifically to preserve their learning value for new human
   contributors. qutip has the same rule
   `[verified — llvm.org/docs/AIToolPolicy.html]`.
2. AI-generated PRs merge at ~32.7% vs ~84.4% for human PRs and wait ~4.6×
   longer for review `[verified — LinearB 2026 benchmark; single vendor,
   methodology not independently checked — directional only]`.

**Consequences are real, not theoretical.** curl terminated its entire
HackerOne bug bounty in Jan 2026 after valid-report rates collapsed from ~1-in-6
to under 5% amid AI slop. Ghostty permanently bans submitters of low-quality AI
PRs. Codeberg voted (71%) to ban hosting of mostly-unreviewed AI repos.
Hacktoberfest disqualifies contributors with 2+ spam-flagged PRs.

### The safe lane

Consistent across every project that permits AI at all: **use it to understand,
discover, and draft privately — never to author what gets submitted.** The risk
lives entirely in what gets submitted, not in private tooling.

Also relevant to the writing half: disclosed AI involvement above ~50%
measurably lowers reader trust, while clearly *assistive* use is received fine
`[verified — arxiv.org/html/2510.24011v1]`.

---

## 4. The agent tooling to build (all inside the safe lane)

Nothing here generates anything that gets submitted anywhere.

1. **Repo-health checker** — computes the §2 metrics for any repo: merge/backlog
   ratio, first-timer merge rate over the last N merged PRs, `good first issue`
   label age, open-PR staleness distribution. This is the tool that would have
   prevented the TypeORM and class-validator traps. Publishable in its own right
   (weaker signal than a merged PR, but it is the honest origin story for the
   writing).
2. **Issue discovery + ranking** — layered on existing feeds (goodfirstissue.dev,
   up-for-grabs.net, CodeTriage) rather than rebuilt. Filters by skill, ranks by
   staleness and competition, and **excludes repos whose policy bans AI
   assistance** so a policy violation is impossible by construction.
3. **Codebase orientation** — summarise architecture and the relevant subsystem
   before diving in. Pure comprehension aid.
4. **PR status tracker** — your own PRs, review latency, what has gone quiet.
5. **Private draft fact-checker** — checks claims in your own writing before you
   publish. Never writes the prose.

---

## 5. Plan shape (~20 weekends)

| Weekends | Focus |
|---|---|
| 1–2 | Build the tooling above. Read the actual CONTRIBUTING.md + AI policy of every shortlisted repo and record what each permits |
| 3–6 | One small PR in a healthy repo, end to end. Scoped fix, 20–300 lines, opened *after* issue discussion |
| 7–16 | Go deep on ONE project: 3–5 substantive PRs, enough that maintainers recognise the name |
| 17–20 | Write-ups; submit one plugin to Anthropic's community marketplace |

**The marketplace gap:** Anthropic's community plugin marketplace holds **3
plugins** against 39 in the curated official list — near-zero competition.
Meanwhile unofficial marketplaces have real traction
(`obra/superpowers-marketplace` ~1.2k★, `trailofbits/skills-curated` ~474★).
`tooling/` here is already built to be portable with no hardcoded paths.
**Publishing one extracted plugin is not publishing the lab** — `ai-research`
stays private (user's decision, 2026-08-02).

### Writing

3–4 posts, each anchored to something actually done. One candidate is already
sitting in this research and is verifiable independently: **the NestJS
ecosystem's default validation library is unmaintained** (class-validator, 0
merges/60d, no commit since Feb 2026). Useful to a lot of people, demonstrates
judgment rather than tutorial-regurgitation, and is exactly the kind of post an
agent could not have written.

---

## 6. OPEN DECISION — which project to go deep on

Deliberately not chosen (user expressed no preference, 2026-08-02). Criteria
rather than a pick:

| Candidate | Choose it if | Cost |
|---|---|---|
| **Vitest** | You want the highest probability of actually landing merged PRs | Testing infra is less differentiating than the AI angle |
| **Promptfoo** | You want the backend track and the AI/evals growth goal in one | Less name-recognition outside AI circles |
| **NestJS** | You want contributions to double as day-job learning for the NAO move | Bot noise; more competition for interesting issues |
| **MCP TS SDK** | You want maximum prestige and to reuse harness knowledge | Heavily Anthropic-maintained — meaningful outside PRs are harder |

Decide by asking which one you will still open on a tired Sunday in November.
Sustained presence in one repo is the only thing the evidence says compounds.

---

## 7. Evidence quality

- **Strong:** all repo metrics (live `gh api`/`gh search`, 2026-08-02);
  the AI-policy landscape (primary policy docs fetched for LLVM, Gentoo, ASF,
  Django, curl).
- **Medium:** hiring-conversion evidence — genuine primary practitioner accounts
  from HN/Blind, but a small, self-selected, mostly-US sample; no controlled
  study of OSS-hours-to-outcome exists anywhere.
- **Weak / flagged:** India-specific hiring signal (could not reach the relevant
  subreddits; indexed content was SEO slop and was discarded); writing-vs-code
  comparison; MCP server-count growth forecast (single blog); the AI merge-rate
  figures (single vendor).
- **Discarded outright:** every precise-looking statistic from career content
  farms ("7 out of 15 hiring managers…"). Several such sources appear to be
  AI-generated. None are cited here.
