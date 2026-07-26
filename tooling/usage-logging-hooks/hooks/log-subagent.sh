#!/bin/bash
# SubagentStop hook — appends every subagent run to <LOG_FILE>, with a truncated
# summary of its final output. Lets a later review see which subagents run, how
# often, and right before which kind of correction. Wire as async.
set -euo pipefail

input=$(cat)
agent_type=$(jq -r '.agent_type // "unknown"' <<<"$input")
session_id=$(jq -r '.session_id // ""' <<<"$input")
last_msg=$(jq -r '.last_assistant_message // ""' <<<"$input")

log_dir="${CLAUDE_PROJECT_DIR}/.claude/logs"        # <LOG_DIR>
mkdir -p "$log_dir"
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

summary=$(printf '%s' "$last_msg" | tr '\n' ' ' | cut -c1-300)

jq -nc --arg ts "$timestamp" --arg sid "$session_id" --arg kind "subagent" \
   --arg name "$agent_type" --arg summary "$summary" \
   '{ts:$ts, session_id:$sid, kind:$kind, name:$name, summary:$summary}' \
   >> "$log_dir/usage.jsonl"                         # <LOG_FILE>

exit 0
