# Project: ai-research (toolkit)

Reusable reference for engineering with AI coding agents: research distilled
into workflows, guides, and portable `.claude/` templates, with primary
sources vendored under `references/`.

Read [README.md](README.md) first — it's the map, and the 60-second
orientation there is the fastest way in.

## Layout

- `CONCEPTS.md` — durable concept map; one line per principle/pattern with its source.
- `references/` — external source material **vendored** (not linked) so it
  can't rot. Each has a `VENDORED.txt` (URL, clone date, commit, upstream
  license). Navigate via `references/README.md`.
- `research/` — dated notes (`YYYY-MM-DD_topic.md`): the *why* behind a practice.
- `workflows/` — end-to-end processes: the *route* to take.
- `guides/` — how-to references for mechanisms (tools, skills vs commands vs
  agents vs hooks, writing skills, context/subagents).
- `catalog/` — decision catalog of agent & skill **patterns**: when each fits,
  pros/cons, efficiency, Maturity/Evidence. Decision-only — links to `tooling/`
  for the deployable artifact, never duplicates it.
- `tooling/` — portable, project-agnostic templates ready to copy into any
  project's `.claude/`. Installed by `/onboard-project`.

Each folder's `README.md` is its live index — if this list and a folder's
`README.md` disagree, the `README.md` is more likely current.

## Conventions

- Anything in `tooling/` must be self-contained enough to copy into another
  project's `.claude/` without modification — only bracketed `<…>`
  placeholders, no hardcoded paths.
- `tooling/` is the **source of truth**; a project copy is a deployment. When a
  template improves in a real project, fold it back here.
- Vendor external references under `references/<name>/` with a `VENDORED.txt`
  and stripped `.git`; add a summary to `references/README.md`.
- Date research notes so they read as a timeline, not a pile.
- Tag load-bearing claims `[verified — source]`, `[self-reported]`, or
  `[hypothesis]`. Never present a vendor's self-reported benchmark as fact.
- Every pattern in `catalog/` carries an honest Maturity flag
  (`Conceptual` / `Template, untested` / `Running`).

## Model usage

- Reserve the main session for research synthesis, tooling design decisions,
  and reviewing results.
- Delegate mechanical work (running a script, summarizing one paper, file
  search) to a subagent on a cheaper model where it doesn't need judgment.
