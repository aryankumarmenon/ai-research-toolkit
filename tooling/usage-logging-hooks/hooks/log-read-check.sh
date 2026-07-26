#!/bin/bash
# PostToolUse hook (matcher: Read) — logs each file read AND actively nudges when
# a session crosses a context-hygiene threshold. Runs SYNCHRONOUSLY (not async)
# so it can inject a message back into context via
# hookSpecificOutput.additionalContext the moment a threshold is crossed —
# fires once per threshold, not on every read after.
#
# Two mechanically-checkable "context overload" warning signs are enforced here:
#   1. more than <FILE_THRESHOLD> files read this session
#   2. re-reading one of <REREAD_FILES> a second time
# Tune both to your own context-budget doc (e.g. a TOKEN_EFFICIENCY.md).
#
# NOTE: hooks can't see real token/context %, so file-count + re-reads are the
# best mechanical PROXY available. Judgment-call signs (scope drift, "reading
# just to be sure") can't be detected by any hook — those stay self-discipline.
set -euo pipefail

# ---- tune these per project -------------------------------------------------
FILE_THRESHOLD=8                     # nudge once the (N+1)th file is read
REREAD_FILES=("CLAUDE.md" "CONTEXT.md")   # <REREAD_FILES>: basenames to watch
EFFICIENCY_DOC="TOKEN_EFFICIENCY.md"      # doc name to cite in the nudge
# -----------------------------------------------------------------------------

input=$(cat)
session_id=$(jq -r '.session_id // ""' <<<"$input")
file_path=$(jq -r '.tool_input.file_path // ""' <<<"$input")

log_dir="${CLAUDE_PROJECT_DIR}/.claude/logs"        # <LOG_DIR>
mkdir -p "$log_dir"
log_file="$log_dir/usage.jsonl"                     # <LOG_FILE>
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

jq -nc --arg ts "$timestamp" --arg sid "$session_id" --arg kind "read" --arg path "$file_path" \
   '{ts:$ts, session_id:$sid, kind:$kind, path:$path}' \
   >> "$log_file"

read_count=$(jq -sc --arg sid "$session_id" \
  '[.[] | select(.session_id==$sid and .kind=="read")] | length' "$log_file" 2>/dev/null || echo 0)

base_name=$(basename "$file_path")
reread_count=0
for watched in "${REREAD_FILES[@]}"; do
  if [[ "$base_name" == "$watched" ]]; then
    reread_count=$(jq -sc --arg sid "$session_id" --arg name "$base_name" \
      '[.[] | select(.session_id==$sid and .kind=="read") | select((.path | split("/") | last) == $name)] | length' \
      "$log_file" 2>/dev/null || echo 0)
    break
  fi
done

context=""
if [[ "$read_count" -eq $((FILE_THRESHOLD + 1)) ]]; then
  context="${EFFICIENCY_DOC} warning sign: this session has now read ${read_count} files — past the '${FILE_THRESHOLD} files' threshold. Worth naming this to the user and considering whether to wrap up/compact soon."
elif [[ "$reread_count" -eq 2 ]]; then
  context="${EFFICIENCY_DOC} warning sign: ${base_name} has now been read twice in this session — an explicit re-read warning sign. Worth flagging."
fi

if [[ -n "$context" ]]; then
  jq -nc --arg ctx "$context" '{hookSpecificOutput:{hookEventName:"PostToolUse", additionalContext:$ctx}}'
fi

exit 0
