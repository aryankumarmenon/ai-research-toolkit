#!/bin/bash
# Stop hook (async) — the automatic-capture half of a human-gated learning loop.
# Incrementally scans usage.jsonl for warn and compaction events and appends
# candidate lesson lines to .claude/logs/pending-lessons.md. A lightweight
# review command (see README "Learning loop pattern") triages the candidates
# with the human and promotes confirmed ones into the project's rule files.
#
# hookify vocabulary:
#   event: Stop  (fires at every response end — safe because scanning is
#                 incremental: a byte-offset marker means each event is
#                 processed exactly once, giving per-iteration capture)
#   action: append [CANDIDATE] lines to pending-lessons.md
#   conditions:
#     - ledger exists
#     - new ledger lines since the stored offset contain kind=="warn"
#       or kind=="compaction"
#
# Offset file: .claude/logs/.lessons-offset-${session_id}
#
# Does NOT append to usage.jsonl itself — that would self-trigger noise on
# the next Stop event.
#
# Platform note: uses stat -f %z for file size (macOS). GNU/Linux: stat -c %s.
set -euo pipefail

ledger="${CLAUDE_PROJECT_DIR}/.claude/logs/usage.jsonl"
if [[ ! -f "$ledger" ]]; then
  exit 0
fi

input=$(cat)
session_id=$(jq -r '.session_id // ""' <<<"$input")

log_dir="${CLAUDE_PROJECT_DIR}/.claude/logs"
mkdir -p "$log_dir"

offset_file="${log_dir}/.lessons-offset-${session_id}"
prev=0
if [[ -f "$offset_file" ]]; then
  prev=$(cat "$offset_file" 2>/dev/null || echo 0)
fi

size=$(stat -f %z "$ledger" 2>/dev/null || echo 0)

if [[ "$size" -le "$prev" ]]; then
  exit 0
fi

# Read only the new region (bytes prev+1 through end)
new_region=$(tail -c +$((prev + 1)) "$ledger" 2>/dev/null || true)

if [[ -z "$new_region" ]]; then
  printf '%d' "$size" > "$offset_file"
  exit 0
fi

warn_lines=$(printf '%s\n' "$new_region" | \
  jq -r 'select(.kind == "warn") | "- [CANDIDATE] \(.ts) · warn:\(.rule // "unknown") · \(.path // "")"' \
  2>/dev/null || true)

compact_lines=$(printf '%s\n' "$new_region" | \
  jq -r 'select(.kind == "compaction") | "- [CANDIDATE] \(.ts) · compaction hit — consider tighter task scoping"' \
  2>/dev/null || true)

# Update offset regardless of whether we found matches
printf '%d' "$size" > "$offset_file"

combined_candidates=""
if [[ -n "$warn_lines" ]]; then
  combined_candidates+="$warn_lines"$'\n'
fi
if [[ -n "$compact_lines" ]]; then
  combined_candidates+="$compact_lines"$'\n'
fi
combined_candidates="${combined_candidates%$'\n'}"

if [[ -z "$combined_candidates" ]]; then
  exit 0
fi

lessons_file="${log_dir}/pending-lessons.md"
today=$(date -u +%F)

header_needed=true
if [[ -f "$lessons_file" ]]; then
  if grep -qF "## Session ${session_id}" "$lessons_file" 2>/dev/null; then
    header_needed=false
  fi
fi

{
  if [[ "$header_needed" = true ]]; then
    printf '\n## Session %s — %s\n' "$session_id" "$today"
  fi
  printf '%s\n' "$combined_candidates"
} >> "$lessons_file"

exit 0
