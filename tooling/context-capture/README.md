# context-capture

A portable bundle that gives every fresh agent instant, lossless context about
your project — the same system running in `ai-research` itself.

## What the bundle is

Four cooperating pieces:

| Piece | File | Role |
|---|---|---|
| **STATE.md snapshot** | `STATE-template.md` | The always-current, rewritten-each-sync snapshot of who the human is, why the repo exists, where things stand, what's next — including a `Verified facts` / `Open failures` split so checked-against-reality claims and still-unresolved attempts don't get conflated. A fresh agent reading it alone can continue. |
| **Append-only journal** | `journal-template.md` | The trail of dated entries — what was done, what was concluded, how it's going. Never rewritten; only prepended to. |
| **SessionStart auto-load** | `load-state.py` | A hook that injects STATE.md as `additionalContext` at the top of every fresh chat — no manual paste needed. |
| **`/sync-context` command** | `sync-context-template.md` | The single writer of both STATE.md and journal.md. Run it at the end of any substantive session. It keeps the snapshot honest and the journal alive. |

### Why bother?

Every new chat starts cold. Without a context-capture system the agent re-derives
orientation from files and conversation history — wasting tokens, sometimes
getting it wrong. STATE.md alone cuts that to a few seconds of reading. The
journal is the trail that makes STATE.md trustworthy: it's how you know the
snapshot is current, not just plausible.

## Install (5 steps)

1. **Copy STATE-template.md → `<project>/STATE.md`** and fill every `<…>`
   placeholder: project name, your role, hard constraints, goal, current state.

2. **Copy journal-template.md → `<project>/research/journal.md`** (create the
   `research/` folder if it doesn't exist). Fill the skeleton entry's placeholders
   or delete it and start fresh on your first real sync.

3. **Copy load-state.py → `<project>/.claude/hooks/load-state.py`** and make it
   executable:
   ```
   chmod +x <project>/.claude/hooks/load-state.py
   ```

4. **Merge settings-snippet.json into `<project>/.claude/settings.json`** (or
   `settings.local.json` if your `.claude/` directory must stay uncommitted — e.g.
   company-visibility constraints). The snippet adds one `SessionStart` hook entry;
   merge it by hand if a `hooks` key already exists. Validate with `jq .` after
   merging.

5. **Copy sync-context-template.md → `<project>/.claude/commands/sync-context.md`**
   and replace every `<project-name>` occurrence with the real project name (or a
   short description of it).

## Conventions

- **STATE.md = snapshot.** Rewritten each sync to reflect reality *now*. Old
  content that no longer reflects the current state is deleted (the journal keeps
  the trail). Keep it lean — it's injected into every session.
- **journal.md = append-only.** Newest entries on top. Never edit old entries.
  The journal is your audit trail and your defence against a stale STATE.md.
- **`/sync-context` is the single writer of both.** Don't update STATE.md or
  journal.md by hand except to fix obvious formatting errors; running the command
  keeps both files consistent with each other.
- **load-state.py fails silent** (`exit 0`, no output) if STATE.md is missing or
  empty. This means you can install the hook before writing STATE.md without
  breaking anything.

---

> **Fold-back note:** the live reference implementation of this bundle is
> `ai-research`'s own `.claude/` — `load-state.py`, `settings.json`
> (SessionStart block), and `.claude/commands/sync-context.md`. If that
> implementation changes materially, update these templates to match.
