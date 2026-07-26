#!/bin/bash
# PreCompact hook — logs every compaction (manual or auto) to <LOG_FILE> as a
# PROXY for "this session ran until it hit the context wall."
#
# IMPORTANT (verified): Claude Code hooks do NOT receive real token counts or
# context-window percentage — that data is not exposed to hooks (only the
# separate statusline mechanism gets it). So this event *firing* is the signal,
# not a number. Frequent compactions across sessions => tasks scoped too large.
#
# The exact field name for manual-vs-auto trigger isn't fully documented, so
# this tries a few plausible keys and falls back to "unknown" rather than
# failing. Wire as async.
set -euo pipefail

input=$(cat)
session_id=$(jq -r '.session_id // ""' <<<"$input")
trigger=$(jq -r '.trigger // .compact_trigger // .reason // "unknown"' <<<"$input")

log_dir="${CLAUDE_PROJECT_DIR}/.claude/logs"        # <LOG_DIR>
mkdir -p "$log_dir"
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

jq -nc --arg ts "$timestamp" --arg sid "$session_id" --arg kind "compaction" --arg trigger "$trigger" \
   '{ts:$ts, session_id:$sid, kind:$kind, trigger:$trigger}' \
   >> "$log_dir/usage.jsonl"                         # <LOG_FILE>

exit 0
