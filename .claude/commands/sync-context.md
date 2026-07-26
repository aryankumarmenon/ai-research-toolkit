---
description: Capture what this session did into ai-research — refresh STATE.md and append a dated journal entry — so a fresh chat has full context
allowed-tools: Read, Edit, Write, Glob, Grep, Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(date:*)
---

Sync the current session's progress into this repo's durable context, so any
future fresh chat can continue without losing anything.

## When to run
At the end of a substantive chunk of AI-research work (new research, a workflow/
guide written, a decision reached, a direction change). Cheap to run often.

## Steps

1. **Gather what changed (read-only).**
   - `git status` and `git diff --stat` for files touched this session.
   - `git log --oneline -5` for recent history (may be empty — local repo).
   - `date +%Y-%m-%d` for today's date.
   - Skim the conversation for: what was done, **conclusions reached**, any change
     in direction, and anything new about the user or the *why*.

2. **Append a journal entry** to `research/journal.md` (newest on top, just under
   the format line). Use this shape — keep it tight, decisions over narration:
   ```markdown
   ## <YYYY-MM-DD> — <short title>

   **What we did**
   - ...

   **What we concluded**
   - ...

   **How it's going / next**
   - ...
   ```
   Don't duplicate content already captured in other files — reference them by path.

3. **Refresh `STATE.md`** (the always-current snapshot). Update only what changed:
   - `_Last synced:_` date.
   - **Current state / how it's going** — rewrite to reflect reality now.
   - **Key conclusions to date** — add genuinely new conclusions; prune anything
     now superseded (this file is a snapshot, not a log — keep it lean).
   - **Open threads / next steps** — add new ones, remove done ones.
   - **About me / Why** — touch only if something material about the user or the
     repo's purpose changed. Don't churn these.

4. **Keep it honest and lean.** STATE.md is auto-loaded into every session, so
   every line costs context — cut stale lines, don't just append. If a conclusion
   is now wrong, fix it; if a thread is done, remove it (the journal keeps the trail).

5. **Report** the journal entry added and the STATE.md sections changed. Do **not**
   commit (committing is the user's call).

6. **Update `CONCEPTS.md`** for genuinely NEW concepts introduced this session.
   One line per concept, in the matching thematic section, using the existing format:
   `- **<concept>** — <compressed description> → \`<source path>\``
   Do NOT add a line just because a file was touched — only if a net-new concept
   or principle was established. Remove or correct any lines that are now superseded.
   Do not create new sections lightly — map into an existing one if reasonable.

## Completion criterion
A fresh agent reading `STATE.md` alone would understand who the user is, why this
repo exists, exactly where things stand, and what to do next — with no gap versus
what this session actually accomplished.
