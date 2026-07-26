#!/bin/bash
# PreToolUse hook (matcher: Read) — blocks redundant reads of unchanged files.
# If the same file/range combination has already been read in this session and
# the file's mtime has not changed, the read is denied with an explanatory
# reason pointing Claude back to the content already in context.
#
# hookify vocabulary:
#   event: PreToolUse
#   matcher: Read
#   action: deny (when redundant) | pass-through (first read or file changed)
#   conditions:
#     - file_path is non-empty
#     - path does NOT contain /.claude/logs/ (ledger files are always allowed)
#     - env CLAUDE_SKIP_REDUNDANT_READ_BLOCK=1 bypasses entirely
#     - key = "file_path|offset|limit" was seen this session AND mtime unchanged
#
# State: per-session JSON object at .claude/logs/read-mtimes-${session_id}.json
# Format: {"path|offset|limit": mtime_integer, ...}
#
# Platform note: uses stat -f %m for mtime (macOS). GNU/Linux: replace with
# stat -c %Y. Adapt as needed for your platform.
set -euo pipefail

# Bypass env var
if [[ "${CLAUDE_SKIP_REDUNDANT_READ_BLOCK:-0}" = "1" ]]; then
  exit 0
fi

input=$(cat)
session_id=$(jq -r '.session_id // ""' <<<"$input")
path=$(jq -r '.tool_input.file_path // empty' <<<"$input")

# Empty path — nothing to track
if [[ -z "$path" ]]; then
  exit 0
fi

# Never block reads of the log files themselves
if [[ "$path" == */.claude/logs/* ]]; then
  exit 0
fi

offset=$(jq -r '.tool_input.offset // 0' <<<"$input")
limit=$(jq -r '.tool_input.limit // 0' <<<"$input")
key="${path}|${offset}|${limit}"

log_dir="${CLAUDE_PROJECT_DIR}/.claude/logs"
mkdir -p "$log_dir"
state_file="${log_dir}/read-mtimes-${session_id}.json"
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Get current mtime — if stat fails (file gone/non-existent), allow the read
# so the tool can produce its own "file not found" error
mtime=$(stat -f %m "$path" 2>/dev/null) || { exit 0; }

# Load existing state (create {} if missing)
if [[ -f "$state_file" ]]; then
  state=$(cat "$state_file")
else
  state="{}"
fi

stored_mtime=$(jq -r --arg k "$key" '.[$k] // empty' <<<"$state")

if [[ -z "$stored_mtime" ]]; then
  # First time seeing this key — record it, allow the read
  new_state=$(jq --arg k "$key" --argjson m "$mtime" '.[$k] = $m' <<<"$state")
  tmp="${state_file}.tmp.$$"
  printf '%s' "$new_state" > "$tmp" && mv "$tmp" "$state_file"
  exit 0
fi

if [[ "$stored_mtime" != "$mtime" ]]; then
  # File changed since last read — update stored mtime, allow the read
  new_state=$(jq --arg k "$key" --argjson m "$mtime" '.[$k] = $m' <<<"$state")
  tmp="${state_file}.tmp.$$"
  printf '%s' "$new_state" > "$tmp" && mv "$tmp" "$state_file"
  exit 0
fi

# Redundant read — deny it
jq -nc --arg ts "$timestamp" --arg sid "$session_id" --arg kind "blocked-read" \
   --arg path "$path" \
   '{ts:$ts, session_id:$sid, kind:$kind, path:$path}' \
   >> "$log_dir/usage.jsonl"

reason="Redundant read blocked: this exact file/range was already read this session and is unchanged (set CLAUDE_SKIP_REDUNDANT_READ_BLOCK=1 to bypass). Use the content already in context."

jq -nc \
  --arg reason "$reason" \
  '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$reason}}'

exit 0
