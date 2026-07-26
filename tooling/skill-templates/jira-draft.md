---
name: jira-draft
description: Draft paste-ready Jira content — epic proposal, story, bug, or sub-tasks/checklist — from repo docs, the conversation, and user-pasted excerpts. No Jira access; output is pasted into Jira manually or handed to the git/MCP-side tool.
disable-model-invocation: true
model: sonnet
allowed-tools: Read, Grep, Glob, Write
---

<!-- Source of truth (ai-research convention: tooling/ is canonical, repo copies
     are deployments). First deployed to sf-nao-admin
     .claude/skills/jira-draft/ on 2026-07-18. See "Deploying" at the bottom. -->

You draft **paste-ready Jira content**. You have **no** Jira, Slack, Figma, or
Confluence access — everything comes from repo docs, this conversation, or
excerpts the user pastes in. The user pastes the result into Jira themselves
(or hands it to whichever tool/agent has Jira access).

## Ticket type & entry gate

Four types. Infer from what the user said; if ambiguous, ask **one**
classification question with a recommendation attached.

| Type | Trigger |
|---|---|
| **Epic (proposal)** | A body of work spanning multiple stories / a broad initiative |
| **Story** | One user-visible capability, one-sprint sized |
| **Bug** | Existing behavior is wrong |
| **Sub-tasks / checklist** | Breaking an existing story/task into steps |

- **Epic gate:** epics are **proposed to the team lead, never drafted as
  create-ready** — the draft's framing must say it's for review. If the
  "epic" is one story's worth of work, recommend a story instead.
- **Bug vs feature ambiguity:** the user's call beats any label — ask once;
  recommend *bug* if current behavior violates an agreed expectation, *story*
  if the expectation itself is new.

## Source sweep — before asking the user anything

Ground yourself first; never ask for something a repo doc already answers.
Check (skip what doesn't exist): <intake/ticket docs> → <PRDs / planned
issues> → <feature guides via your docs router> → <project glossary> →
<known-issues / recurring-mistakes catalog (bugs)> → this conversation.

Mark every fact **Confirmed** (repo doc / verified this session) or
**Provisional** (pasted, recalled, unverified). Provisional load-bearing facts
surface as open questions.

## Gap interview

Draft a mental skeleton against the template, list gaps, fill them **one
question at a time**, recommendation attached. For external material make
**targeted paste requests** ("paste the Figma frame notes for X", "paste the
Slack thread where severity was discussed"). "I don't know" → offer 2–3
options, don't re-ask. Unfillable requireds become `[OPEN — needs <source>]`
in the draft — never silently invent.

## Jira formatting rules (paste-safety)

- Headings, **bold**, lists, `inline code` survive paste into Jira Cloud. Use freely.
- **No HTML, no markdown tables** — bold-label lines instead (`**Environment:** …`).
- Given/When/Then as bold-prefixed bullets, ≤2 nesting levels.
- Code blocks only for payloads / error text / traces.
- Wrap the final draft in a `~~~` outer fence (one copy action).
- **Invisibility:** drafts are company-visible — never reference local AI
  tooling, `.claude/`, or your agent setup inside a draft.

## Quality self-check (run before presenting; fix silently, report judgement calls)

**All types:** facts Confirmed/Provisional · glossary terms only · zero
tooling references · paste-safe · summary phrased as outcome, not implementation.

**Epic:** proposal framing · problem statement · Scope In+Out · deps & risks ·
epic-level AC tied to a success metric (or metric flagged `[OPEN]`).

**Story:** real persona (never "as a user") · 2–5 Given/When/Then ACs (>5 →
recommend split + propose the cut) · INVEST · one-sprint sized · no
parent-epic-AC duplication.

**Bug:** stranger-followable numbered repro · Expected vs Actual labeled ·
environment/client + org tier · severity **with** impact×frequency rationale ·
evidence or `[OPEN — needs log paste]` · no asserted root cause.

**Sub-tasks:** one level only · dozens-of-steps-one-person → checklist instead
(say why) · dependency-chained items → probably stories under an epic, escalate.

## Output

Chat-first in one `~~~` fence. On explicit request save to a git-excluded
local dir (e.g. `.claude/jira-drafts/`). Never into the inbound
ticket-intake dir — a draft there masquerades as a real fetched ticket.
End by naming the next step (paste into Jira / hand to the Jira-capable tool;
re-ingest via your intake workflow once it's a real ticket).

---

## Templates (deploy as `templates/<type>.md`; `<!-- guidance -->` never emitted)

### epic.md

**Proposed epic — drafted for review and discussion, not yet created.**
`## Summary` outcome-phrased ≤10 words → `## Problem statement` 2–4 sentences →
`## Proposed outcome & success metric` (one measurable metric; `[OPEN]` if
none elicited — an epic is done when the outcome is real, not when children
close) → `## Scope` **In:** / **Out:** lists → `## Candidate stories` 3–7
story-form one-liners → `## Dependencies & risks` bold-label bullets →
`## Acceptance criteria (epic-level)` 2–4 GWT tied to the metric, not a union
of child ACs.

### story.md

`## Summary` user-visible verb phrase → `## Story`
`As a <persona>, I want <capability>, so that <value>.` (real personas from
your product; value must be real) → `## Context` 1–3 sentences + supplied
links; if parent epic carries feature ACs, reference it and keep ACs below
story-specific → `## Acceptance criteria` 2–5 GWT bold-prefix bullets →
`## Out of scope` optional bullets. INVEST applied at self-check.

### bug.md

`## Summary` `<where>: <symptom>` → `## Environment` bold-label lines
(client, org tier, version — looked up, never remembered; unknowns `[OPEN]`) →
`## Steps to reproduce` numbered from clean state → `## Expected result` (cite
the expectation's source) → `## Actual result` → `## Evidence` code block or
`[OPEN — needs paste]` → `## Severity & rationale` proposed + impact×frequency
(triage decides) → `## Suspected area` optional, hypothesis-marked, delete if
it's just a guess.

### subtask.md

Decision gate first (≤~8 pieces / different people → sub-tasks; dozens for one
person → checklist in parent description; dependency chain → stories under an
epic, escalate). Emit only the chosen form.
Sub-task form: `## Sub-task: <action verb phrase>` + 1–2 line description +
`**Done when:** <one observable condition>`. Checklist form: `## Checklist`
of ordered `- [ ]` action items for the parent's description.

---

## Deploying

1. Split into `SKILL.md` + `templates/{epic,story,bug,subtask}.md` in the
   target repo's skills dir — keep it **git-excluded** if company-visibility
   rules apply.
2. Fill project specifics: Jira site + ticket prefix (`<PROJECT>-XXXX`), doc
   paths for the source sweep (intake, PRDs, issues, feature guides, glossary,
   known-issues catalog), real persona list, client/tenant list, and the local
   save dir.
3. If the repo has a pipeline router skill (e.g. which-step), add a routing row.
4. Verify without Jira: story path against a real intake doc (sweep before
   questions, 2–5 ACs); gap path on an invented feature (targeted pastes,
   `[OPEN]` markers); epic gate (proposal framing + metric); bug path with no
   env given (asks client/env first, severity has rationale); 7-AC story
   (recommends split); grep drafts for tooling references (zero hits); confirm
   nothing became committable.
