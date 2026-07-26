---
name: review
description: Two-axis review of a diff — Standards (follows the repo's documented coding standards?) and Spec (matches what the issue/PRD asked?). Runs both as parallel subagents in fresh context and reports them side by side.
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, Task
---

# Two-Axis Review

Review the diff between `HEAD` and a fixed point along two independent axes:

- **Standards** — does the code conform to this repo's documented coding standards?
- **Spec** — does the code faithfully implement the originating issue/PRD?

Run both as **parallel subagents** so they don't pollute each other's context,
then aggregate. **Run this in fresh context** (ideally right after `/clear`) —
never tacked onto the session that wrote the diff; the implementer is past the
point where it reliably catches its own deviations.

## Process

### 1. Pin the fixed point
A commit SHA, branch, tag, `main`, or `HEAD~5`. If the user didn't say, ask.
Capture: `git diff <fixed-point>...HEAD` (three-dot, vs merge-base) and
`git log <fixed-point>..HEAD --oneline`. Confirm the ref resolves and the diff is
non-empty *before* spawning subagents — a bad ref should fail here, not inside them.

### 2. Identify the spec source
Issue refs in commit messages → a path the user passed → a PRD/spec file under
`<docs/ specs/ .scratch/>` matching the branch. If none, ask; if there genuinely
is none, the Spec axis reports "no spec available".

### 3. Identify the standards sources
<!-- Replace with this repo's standards files. -->
`<e.g. .claude/rules/*.md, CODING_STANDARDS.md, CONTRIBUTING.md>`. **Push these
into the subagent's context explicitly** — don't assume auto-load fired.

### 4. Spawn both subagents in parallel (one message, two Agent calls)

Pin both to a cheaper model (`model: sonnet`) — checking a diff against a fixed
rule set or spec doesn't need the session model's reasoning tier.

**Confidence rubric — both subagents apply this per finding:**
- 91–100: explicit rule-file violation (quote the exact rule verbatim) or a
  definite compile error / wrong-result bug
- 76–90: important — security/correctness with real blast radius
- 51–75: valid but low-impact
- 0–50: nitpick / likely false positive

**Threshold rule:** surface **only findings ≥ 75**; report lower-scoring ones as
a count only ("+3 below threshold").

**Finding format:** `file:line · confidence · "exact rule or spec text quoted" ·
concrete fix`

**Standards subagent** — give it the diff command, commit list, and standards
files. Brief: "Score each finding 0–100 with the rubric. Report every place the
diff violates a documented standard, citing the standard (file + rule).
Distinguish hard violations from judgment calls. Skip anything tooling enforces.
Surface only ≥ 75 in the finding format; count the rest. Under 400 words."

**Spec subagent** — give it the diff command, commit list, and the spec contents.
Brief: "Score each finding 0–100 with the rubric. Report (a) spec requirements
missing/partial; (b) behavior not asked for (scope creep — flag anything touching
the spec's Out-of-Scope); (c) requirements that look implemented but wrong. Quote
the spec line for each. Surface only ≥ 75 in the finding format; count the rest.
Under 400 words."

If the spec is missing, skip the Spec subagent and note it.

### 5. Validate (false-positive kill pass)
Before presenting, re-check each surfaced ≥ 76 finding against the actual code
(batch, cheap model): does the code really do what the finding claims? If a
finding doesn't hold up, **drop it**. Keep the axes separate while validating.
Precision is the goal — a confident-looking finding contradicted by the code
does more harm than a small missed issue.

### 6. Aggregate
Present validated findings under `## Standards` and `## Spec`, verbatim or lightly
cleaned. **Do NOT merge or rerank** — separation stops one axis masking the other.
End with a one-line summary: findings per axis + the worst issue *within each
axis*. Don't pick a cross-axis winner. Fix nothing — report back to the
implementing session.

## Why two axes
Code can follow every standard but implement the wrong thing (Standards pass, Spec
fail), or do exactly what was asked while breaking conventions (Spec pass,
Standards fail). Reporting them separately keeps either from hiding the other.
