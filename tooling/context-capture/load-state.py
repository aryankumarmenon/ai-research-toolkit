#!/usr/bin/env python3
"""SessionStart hook: inject STATE.md so every fresh chat starts with full
context. Reads $CLAUDE_PROJECT_DIR/STATE.md and returns it as additionalContext.
Fails silent (exit 0, no output) if the file is missing or empty.

$CLAUDE_PROJECT_DIR is set by Claude Code to the project root. If it is not set
(e.g. running the script manually), falls back to the current working directory."""
import json
import os
import sys

root = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
path = os.path.join(root, "STATE.md")

try:
    with open(path, "r", encoding="utf-8") as f:
        content = f.read().strip()
except OSError:
    sys.exit(0)

if not content:
    sys.exit(0)

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": content,
    }
}))
