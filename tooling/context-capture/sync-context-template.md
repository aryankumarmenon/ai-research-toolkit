---
description: Capture what this session did into <project-name> — refresh STATE.md and append a dated journal entry — so a fresh chat has full context
allowed-tools: Read, Edit, Write, Glob, Grep, Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(date:*)
---

Sync the current session's progress into this repo's durable context, so any
future fresh chat can continue without losing anything.

## When to run
At the end of a substantive chunk of work (new research, a feature completed, a
decision reached, a direction change). Cheap to run often.

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
   - **Current state** — a *snapshot*, **never** a log. **Do not add a dated
     entry here**; dated narrative belongs in the journal (step 2) and nowhere
     else. *Replace* this section's contents rather than appending to them.
     If you are writing a date into this section, you are in the wrong file.
   - **Key conclusions to date** — add genuinely new conclusions; prune anything
     now superseded (snapshot, not a log — keep it lean).
   - **Active threads / next steps** — add new threads; when one closes, move it
     to the **Resolved** table with its ID intact. **Never renumber** (the
     journal cites threads by number). If a closing thread leaves real work
     behind, give that work its **own new ID** in the active list — don't park
     it inside a resolved row, where it goes unread.
   - **About me / Why** — touch only if something material about the user or the
     repo's purpose changed. Don't churn these.
   - Never record file/folder **counts** ("5 guides", "three research notes") —
     they rot between reads. Point at the folder's `README.md` index instead.

4. **Keep it honest and lean.** STATE.md is auto-loaded into every session, so
   every line costs context — cut stale lines, don't just append. If a conclusion
   is now wrong, fix it; if a thread is done, move it (the journal keeps the trail).
   **Size guard:** if STATE.md passes ~350 lines, stop and look for a log that has
   crept back into *Current state* — that is the known failure mode, and it
   returns one reasonable-looking dated bullet at a time.

5. **Report** the journal entry added and the STATE.md sections changed. Do **not**
   commit (committing is the user's call).

## Completion criterion
A fresh agent reading `STATE.md` alone would understand who the user is, why this
repo exists, exactly where things stand, and what to do next — with no gap versus
what this session actually accomplished.
