# CLAUDE.md block: laziness ladder

Paste-in block for a project's `CLAUDE.md` (or `CLAUDE.local.md`). Distilled
from the vendored [ponytail](../../references/ponytail/) ruleset (MIT,
DietrichGebert/ponytail) — the write-time counterpart to review-time
over-engineering defenses (design-reviewer, deletion test). ~15 lines resident
cost; per instruction-file discipline, drop it if the repo's diffs are already
consistently minimal.

Copy everything between the markers:

<!-- BLOCK START -->
## Before writing code (laziness ladder)

Understand the problem first (trace the real flow end to end), then stop at the
first rung that holds:

1. Doesn't need to exist (YAGNI) → 2. already in this codebase (reuse it) →
3. stdlib → 4. native platform feature → 5. installed dependency →
6. one line → 7. only then: minimum code that works.

- No unrequested abstractions, dependencies, or boilerplate. Deletion over
  addition; boring over clever; shortest working diff — in the right place.
- Bug fix = root cause: grep every caller, fix the shared function once.
- Mark deliberate corner-cuts with a comment naming the ceiling + upgrade path.
- NOT lazy about: problem comprehension, trust-boundary validation, error
  handling that prevents data loss, security, accessibility, anything
  explicitly requested. Non-trivial logic leaves one runnable check behind.
<!-- BLOCK END -->
