#!/bin/bash
# UserPromptSubmit hook — appends explicit /command (or /skill) invocations to
# <LOG_FILE>. Heuristic: the message's first line starts with '/' followed by a
# word (matches how a slash command is actually typed; avoids false-matching a
# pasted file path mid-message). Wire as async — zero token cost, non-blocking.
set -euo pipefail

input=$(cat)
message=$(jq -r '.user_message // ""' <<<"$input")
session_id=$(jq -r '.session_id // ""' <<<"$input")

first_line="$(printf '%s' "$message" | head -n1)"

if [[ "$first_line" =~ ^/([a-zA-Z][a-zA-Z0-9_-]*)([[:space:]]+(.*))?$ ]]; then
  cmd="${BASH_REMATCH[1]}"
  args="${BASH_REMATCH[3]:-}"
  log_dir="${CLAUDE_PROJECT_DIR}/.claude/logs"     # <LOG_DIR>
  mkdir -p "$log_dir"
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  jq -nc --arg ts "$timestamp" --arg sid "$session_id" --arg kind "command" \
     --arg name "$cmd" --arg args "$args" \
     '{ts:$ts, session_id:$sid, kind:$kind, name:$name, args:$args}' \
     >> "$log_dir/usage.jsonl"                      # <LOG_FILE>
fi

exit 0
