#!/bin/bash
# PostToolUse hook (matcher: Bash) — replaces verbose test-runner output with
# just the lines that matter (failures, errors, summary). Real token savings:
# PostToolUse hooks CAN replace the tool result the model sees, via
# hookSpecificOutput.updatedToolOutput (doc-verified 2026-07-04).
#
# ADAPT BEFORE USE:
#   <TEST_COMMAND_REGEX> — grep -E pattern matching your test command,
#     e.g. 'sf apex run test' / 'npm (run )?test' / 'pytest'
#   <FILTER_KEYWORDS_REGEX> — grep -E pattern for lines to keep,
#     e.g. 'Fail|Error|error|Assert|Exception|Outcome|Coverage|coverage'
#   MIN_LINES (default 80) — below this, output passes through unfiltered
#
# hookify vocabulary:
#   event: PostToolUse
#   matcher: Bash
#   action: replace tool output (updatedToolOutput) when applicable
#   conditions:
#     - CLAUDE_SKIP_TEST_FILTER != "1"  (escape hatch)
#     - tool_input.command matches <TEST_COMMAND_REGEX>
#     - raw output >= MIN_LINES lines
set -euo pipefail

TEST_COMMAND_REGEX='<TEST_COMMAND_REGEX>'
FILTER_KEYWORDS_REGEX='<FILTER_KEYWORDS_REGEX>'
MIN_LINES=80

# Bypass env var
if [[ "${CLAUDE_SKIP_TEST_FILTER:-0}" = "1" ]]; then
  exit 0
fi

input=$(cat)
session_id=$(jq -r '.session_id // ""' <<<"$input")
command=$(jq -r '.tool_input.command // ""' <<<"$input")

# Only act on test-runner commands
if ! printf '%s' "$command" | grep -qE "$TEST_COMMAND_REGEX"; then
  exit 0
fi

# Extract output text defensively (payload shape varies)
raw_output=$(jq -r '.tool_response.stdout // .tool_response.output // (.tool_response | tostring)' <<<"$input")

line_count=$(printf '%s\n' "$raw_output" | wc -l | tr -d ' ')

# Not worth filtering short output
if [[ "$line_count" -lt "$MIN_LINES" ]]; then
  exit 0
fi

# Keep keyword-matched lines + last 15 lines (summary table), deduped in order
matched_lines=$(printf '%s\n' "$raw_output" | grep -E "$FILTER_KEYWORDS_REGEX" || true)
tail_lines=$(printf '%s\n' "$raw_output" | tail -n 15)
combined=$(printf '%s\n%s\n' "$matched_lines" "$tail_lines" | awk '!seen[$0]++')
filtered_count=$(printf '%s\n' "$combined" | wc -l | tr -d ' ')

header="[filtered by hook: ${line_count}→${filtered_count} lines; full output not retained — rerun with CLAUDE_SKIP_TEST_FILTER=1 for raw]"
filtered_output="${header}
${combined}"

# Ledger line so a retro pass can quantify the savings
log_dir="${CLAUDE_PROJECT_DIR}/.claude/logs"
mkdir -p "$log_dir"
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
jq -nc --arg ts "$timestamp" --arg sid "$session_id" --arg kind "filtered-output" \
   --arg detail "${line_count}->${filtered_count} lines" \
   '{ts:$ts, session_id:$sid, kind:$kind, detail:$detail}' \
   >> "$log_dir/usage.jsonl"

# Emit the replacement output
jq -nc --arg out "$filtered_output" \
  '{hookSpecificOutput:{hookEventName:"PostToolUse",updatedToolOutput:$out}}'

exit 0
